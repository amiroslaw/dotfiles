#!/usr/bin/env python3
import dataclasses
import datetime
import json
import sys

# doesn't cover what timew shows
TZ_OFFSET = datetime.timedelta(hours=-5)
FIRST_WEEK_DAY = 7  # Saturday


@dataclasses.dataclass
class WeekCounter:
    end: datetime.date
    time: datetime.timedelta = datetime.timedelta(0)


@dataclasses.dataclass
class Interval:
    start: datetime.datetime
    end: datetime.datetime

    @property
    def duration(self):
        return self.end - self.start

def read_json():
    if len(sys.argv) > 1:
        with open(sys.argv[1], "r") as file_:
            data = file_.read().splitlines()
    else:
        data = sys.stdin.read().splitlines()
    line = None
    for line, value in enumerate(data):
        if not value:
            break
    if line is None:
        return
    data = json.loads("".join(data[line:]))

    return data


def make_dates(interval):
    parse_dt = lambda x: datetime.datetime.strptime(x, "%Y%m%dT%H%M%SZ")
    parsed = start = parse_dt(interval["start"]) + TZ_OFFSET
    if "end" in interval:
        end = parse_dt(interval["end"]) + TZ_OFFSET
    else:
        end = datetime.datetime.utcnow() + TZ_OFFSET
    return Interval(start=start, end=end)


def split_interval(interval, end):
    if interval.end < end:
        return [WeekCounter(end=end, time=interval.duration)]

    intervals = []

    while end < interval.start:
        intervals.append(WeekCounter(end=end))
        end = end + datetime.timedelta(days=7)

    # Create new interval to avoid mutating input
    interval = Interval(start=interval.start, end=interval.end)
    while interval.start < interval.end:
        stop = min(end, interval.end)
        intervals.append(WeekCounter(end=end, time=stop - interval.start))
        interval.start = stop
        if end == interval.start:
            end = end + datetime.timedelta(days=7)

    return intervals


def main():
    data = read_json()
    data = [make_dates(d) for d in data]

    start = data[0].start
    days_to_end_week = ((FIRST_WEEK_DAY - start.weekday()) % 7) or 7
    end_week = (
        datetime.datetime(start.year, start.month, start.day) +
        datetime.timedelta(days=days_to_end_week)
    )
    weeks = [WeekCounter(end=end_week)]
    for interval in data:
        splits = split_interval(interval, weeks[-1].end)
        for split in splits:
            if split.end == weeks[-1].end:
                weeks[-1].time += split.time
            else:
                weeks.append(split)

    for week in weeks:
        date = (week.end - datetime.timedelta(days=1)).strftime("%Y-%m-%d")
        days = week.time.total_seconds() / 60 / 60
        print(f"Week ending {date}: {days:0.1f} hours")


if __name__ == "__main__":
    main()
