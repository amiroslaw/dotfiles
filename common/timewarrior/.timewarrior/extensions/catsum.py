#!/usr/bin/env python3

###############################################################################
#
# Category Summaries
#
#
###############################################################################

import datetime
import io
import json
import logging
import pprint
import sys

from typing import Dict, Any

from dateutil import tz

# set logging
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

# create handler
c_handler = logging.StreamHandler()
c_handler.setLevel(logging.INFO)

# Create formatters and add it to handlers
LOG_FORMAT = "[%(asctime)s - %(levelname)-8s - %(module)s:%(name)s ] %(message)s"
c_format = logging.Formatter(LOG_FORMAT)
c_handler.setFormatter(c_format)

# Add handlers to the logger
logger.addHandler(c_handler)

DATE_FORMAT = "%Y%m%dT%H%M%SZ"

# TODO: Convert to defaultdict
# https://www.accelebrate.com/blog/using-defaultdict-python
# https://stackoverflow.com/questions/9358983/dictionaries-and-default-values
# https://docs.python.org/2/library/collections.html#collections.defaultdict
CATEGORIES: dict = {
    "PT": "Personal Time",
    "PW": "Planned Work",
    "UW": "Unplanned Work",
    "OW": "Other Work",
}


def main():
    print("~" * 100)
    totals = calculate_totals(sys.stdin)
    # print(totals)

    if not totals:
        sys.exit(0)

    categories_total = extract_categories(totals)

    # All Categories Statistics
    category_percent_breakdown = get_category_percent_breakdown(categories_total)
    formatted_category_breakdown = format_category_breakdown(category_percent_breakdown)
    display_category_breakdown(formatted_category_breakdown)

    # remove personal category
    categories_total.pop("Personal Time", None)
    work_category_percent_breakdown = get_category_percent_breakdown(categories_total)
    formatted_work_category_breakdown = format_category_breakdown(work_category_percent_breakdown)
    display_category_breakdown(formatted_work_category_breakdown)
    # formatted_category_breakdown.pop("Personal Time", None)
    # formatted
    # print(type(formatted_category_breakdown))

    # print(formatted_category_breakdown.keys())


def format_seconds(seconds: int) -> str:
    """
    Convert seconds to a formatted string

    Convert seconds: 3661
    To formatted: "   1:01:01"
    """
    # print(seconds, type(seconds))
    hours = seconds // 3600
    minutes = seconds % 3600 // 60
    seconds = seconds % 60
    return f"{hours:4d}:{minutes:02d}:{seconds:02d}"


def calculate_totals(input_stream: io.TextIOWrapper) -> Dict[str, datetime.timedelta]:
    from_zone = tz.tzutc()
    to_zone = tz.tzlocal()

    # Extract the configuration settings.
    header = 1
    configuration = dict()
    body = ""
    for line in input_stream:
        if header:
            if line == "\n":
                header = 0
            else:
                fields = line.strip().split(": ", 2)
                if len(fields) == 2:
                    configuration[fields[0]] = fields[1]
                else:
                    configuration[fields[0]] = ""
        else:
            body += line

    # Sum the seconds tracked by tag
    totals = dict()
    untagged = None
    j = json.loads(body)
    for object in j:
        start = datetime.datetime.strptime(object["start"], DATE_FORMAT)

        if "end" in object:
            end = datetime.datetime.strptime(object["end"], DATE_FORMAT)
        else:
            end = datetime.datetime.utcnow()

        tracked = end - start

        if "tags" not in object or object["tags"] == []:
            if untagged is None:
                untagged = tracked
            else:
                untagged += tracked
        else:
            for tag in object["tags"]:
                if tag in totals:
                    totals[tag] += tracked
                else:
                    totals[tag] = tracked

    if "temp.report.start" not in configuration:
        print("There is no data in the database")
        return totals

    start_utc = datetime.datetime.strptime(configuration["temp.report.start"], DATE_FORMAT)
    start_utc = start_utc.replace(tzinfo=from_zone)
    start = start_utc.astimezone(to_zone)

    if "temp.report.end" in configuration:
        end_utc = datetime.datetime.strptime(configuration["temp.report.end"], DATE_FORMAT)
        end_utc = end_utc.replace(tzinfo=from_zone)
        end = end_utc.astimezone(to_zone)
    else:
        end = datetime.datetime.now()

    if len(totals) == 0 and untagged is None:
        print(f"No data in the range {start:%Y-%m-%d %H:%M:%S} - {end:%Y-%m-%d %H:%M:%S}")
        return totals

    print(f"\nCategory Summary Data for {start:%Y-%m-%d %H:%M:%S} - {end:%Y-%m-%d %H:%M:%S}")

    return totals


def extract_categories(totals: Dict[str, datetime.timedelta]) -> Dict[str, datetime.timedelta]:
    categories_total = {}
    for category, category_full_name in CATEGORIES.items():
        categories_total[category_full_name] = totals.get(category, datetime.timedelta(0))
    return categories_total


def get_category_percent_breakdown(
    category_run_times: Dict[str, datetime.timedelta]
) -> Dict[str, Any]:
    logger.debug("Getting category percentage breakdown...")
    total_time = sum([run_time.total_seconds() for run_time in category_run_times.values()])
    logger.debug(f"Total Time:{total_time}")

    category_percentage_breakdown: dict = {}
    for category, run_time in category_run_times.items():
        category_percent = run_time.total_seconds() / total_time
        category_percentage_breakdown[category] = {
            "percent": category_percent,
            "duration": run_time.total_seconds() / 60,
            "run_time": format_seconds(int(run_time.total_seconds())),
        }

    # add total time statistics
    category_percentage_breakdown["Total"] = {
        "percent": total_time / total_time,
        "duration": total_time / 60,
        "run_time": format_seconds(int(total_time)),
    }

    logger.debug(pprint.pformat(category_percentage_breakdown))
    return category_percentage_breakdown


def format_category_breakdown(category_breakdown: dict) -> Dict[str, Any]:
    # print(type(category_breakdown))
    # pprint.pprint(category_breakdown)
    formatted_category_breakdown = {}
    for category, category_statistics in category_breakdown.items():
        formatted_category_breakdown[category] = {
            # convert duration to mins
            "duration": round(category_statistics["duration"], 2),
            "percent": round(category_statistics["percent"] * 100, 2),
            "run_time": category_statistics["run_time"],
        }
    return formatted_category_breakdown


def display_category_breakdown(category_breakdown: dict, title: str = "Category Breakdown"):

    # Determine largest width
    max_width = len("Category")
    for category_statistics in category_breakdown.values():
        if len(category_statistics) > max_width:
            max_width = len(category_statistics)

    print_dotted_line()
    print(f"\t\t{title.capitalize():>{max_width}}")
    print(
        f"{'Category':{max_width}}\t"
        f"{'Duration':{max_width}}\t"
        f"{'Run_Time':>{max_width + 2}}\t"
        f"{'Percent':{max_width + 1}}"
    )
    for category, category_statistics in category_breakdown.items():
        print(
            f"{category:{max_width}}\t"
            f"{category_statistics['duration']:{max_width}}\t"
            f"{category_statistics['run_time']:}\t"
            f"{category_statistics['percent']}%"
        )
    print_dotted_line()


def print_dotted_line(width: int = 72):
    """Print a dotted (rather 'dashed') line"""
    print("-" * width)


if __name__ == "__main__":
    main()
