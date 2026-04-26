import ralph


def test_format_duration_basic():
    assert ralph.format_duration(0.0) == "0s"


def test_format_duration_hour_plus_exact():
    assert ralph.format_duration(3725.0) == "1h02m05s"
