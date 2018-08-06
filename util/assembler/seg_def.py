from enum import Enum, unique


@unique
class Segment(Enum):
    Text = 0
    Data = 1
