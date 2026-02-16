#!/usr/bin/env python3
"""
timewarrior report for generating weekly timecard. It assumes that each
interval has exactly one tag that is in the configuration variable
timesheet.projects. There can be other tags, but one must be in that list. The
tags that remain are codes that can be placed on the timesheet.
"""

from __future__ import print_function

import sys
import json
import decimal

from decimal import Decimal
from functools import partial, reduce
from io import StringIO

from datetime import datetime
from dateutil import parser
from dateutil.tz import tzlocal

DAYS_IN_WEEK = 7
TENTHS_OF_HOURS = Decimal('0.1')
SECONDS_IN_HOUR = Decimal('3600.0')

class LocalException(Exception):
    """Generic report exception."""
    pass

class Interval(object):
    """Inteval is an object that represents a single time interval."""
    def __init__(self, interval_string, config):
        json_object = json.loads(interval_string)

        if "tags" not in json_object:
            raise LocalException("Interval found without any tags. "
                                 "Please fix and rerun report. "
                                 "Interval is '{}'".format(json_object))

        projects = [x for x in json_object["tags"] if x in config["projects"] ]

        if len(projects) == 0:
            raise LocalException("Found interval @{} without valid project. "
                                 "Please fix and then rerun report.\n".format(json_object["id"]) +
                                 str(json_object))

        if len(projects) > 1:
            raise LocalException("Interval @{1} tagged with {0}. Intervals must have one and only one tagged project.".format(", ".join(projects), json_object["id"]))

        local_tz = tzlocal()
        self._tag = projects[0]

        start = parser.parse(json_object["start"]).astimezone(local_tz)

        # If the interval is still open, just assume that we'll close it with
        # the current time.
        if "end" in json_object:
            end = parser.parse(json_object["end"]).astimezone(local_tz)
        else:
            end = datetime.now(local_tz)

        self._total_seconds = int((end - start).total_seconds())
        self._weekday = start.weekday()

    def tag(self):
        """Returns the tag for this interval."""
        return self._tag

    def total_seconds(self):
        """Returns the total number of seconds for this interval."""
        return self._total_seconds

    def weekday(self):
        """Return the weekday number for this interval."""
        return self._weekday

class Report(object):
    """A report in the format that can be printed for starlab given the intervals.."""
    def __init__(self, input_stream):
        config = self._parse_options(sys.stdin)
        intervals = self._stream_to_intervals(input_stream, config)
        self._data = self._intervals_to_data(intervals)
        self._tag_width = reduce(max, (len(value[0]) for value in self._data), 3)
        self._column_width = 6

    @staticmethod
    def _parse_options(input_stream):
        """Skip over all the report options."""
        config = dict()
        config["projects"] = []
        for line in input_stream:
            line = line.strip()
            if line.startswith("timesheet.projects"):
                projects = line.split(":", 1)[1].strip()
                config["projects"] = json.loads(projects)
            if line == "":
                return config
        raise LocalException("No separator between options and intervals?")

    @staticmethod
    def _stream_to_intervals(input_stream, config):
        intervals = list()
        for line in input_stream:
            line = line.strip("\n,")
            if line == "" or line.startswith("[") or line.startswith("]"):
                continue
            try:
                intervals.append(Interval(line, config))
            except ValueError as exception:
                print("Error parsing intervals: {} in '{}'".format(exception, line))
                raise
        return intervals

    @staticmethod
    def _intervals_to_data(intervals):
        projects = {}

        if not intervals:
            intervals = []

        # The first pass collects all the intervals into daily second totals
        # per project
        for interval in intervals:
            if interval.tag() not in projects:
                projects[interval.tag()] = [0]*DAYS_IN_WEEK
            projects[interval.tag()][interval.weekday()] += interval.total_seconds()

        # Now we'll organize the daily projects totals into tenth's of hours
        # to be used when summarizing the daily totals. In this way, the math
        # of this report will match the online timekeeping systems projects
        # and daily totals.

        project_keys = list(projects.keys())
        project_keys.sort()

        rows = []
        for key in project_keys:
            row = [None]*len(projects[key])
            for day, total_seconds in enumerate(projects[key]):
                value = (Decimal(total_seconds) / SECONDS_IN_HOUR)
                row[day] = value.quantize(TENTHS_OF_HOURS,
                                          rounding=decimal.ROUND_HALF_UP)
            rows.append((key, row))

        # Now sum up the totals
        daily_totals = [Decimal()]*DAYS_IN_WEEK
        for _, data in rows:
            project_total = Decimal()
            for day, value in enumerate(data):
                project_total += value
                daily_totals[day] += value
            data.append(project_total)
        daily_totals.append(sum(daily_totals, Decimal()))
        rows.append(('totals', daily_totals))
        return rows

    @staticmethod
    def _get_separator(tag_width, column_width):
        separator = "="*tag_width + "=|"
        for _ in range(DAYS_IN_WEEK + 1):
            separator += "="*column_width + "==|"
        return separator

    def _print_header(self, put_fn):
        put_fn("{:{}s} |".format(" " * self._tag_width, self._tag_width))
        for day in ("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun", "Tot"):
            put_fn(" {:>{}s} |".format(day, self._column_width))
        put_fn("\n")
        put_fn(self._get_separator(self._tag_width, self._column_width))
        put_fn("\n")

    def _print_footer(self, put_fn):
        put_fn(self._get_separator(self._tag_width, self._column_width))
        put_fn("\n")

    def _write_row_data(self, put_fn, row):
        for day in row:
            if day > 0:
                put_fn("{:{}f} | ".format(day, self._column_width))
            else:
                put_fn("{:{}s} | ".format(" ", self._column_width))
        put_fn("\n")

    def _write_row(self, put_fn, row):
        tag, data = row
        put_fn("{:{}s} | ".format(tag, self._tag_width))
        self._write_row_data(put_fn, data)

    def write(self, output_stream):
        """Write a formatted report to the file specified by output_stream."""
        puts = partial(print, end="", file=output_stream)
        self._print_header(puts)
        for row in self._data[0:-1]:
            self._write_row(puts, row)
        self._print_footer(puts)
        self._write_row(puts, self._data[-1])

    def __str__(self):
        output = StringIO()
        for project, data in self._data:
            output.write("{} : {}\n".format(project, data))
        return output.getvalue()

def main():
    """Run the report, writing the output to stream."""
    try:
        Report(sys.stdin).write(sys.stdout)
    except KeyError as exception:
        if exception.args[0] == 'id':
            print("Failed to find interval id in report input. Please update timewarrior to 1.3.0 or greater.",
                  file=sys.stderr)
        else:
            raise
    return 0

if __name__ == "__main__":
    try:
        sys.exit(main())
    except LocalException as exception:
        print("Report failed: {}\n".format(exception), end="")
        sys.exit(1)
