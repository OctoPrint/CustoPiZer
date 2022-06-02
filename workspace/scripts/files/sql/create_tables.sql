CREATE TABLE IF NOT EXISTS od_readings_raw (
    timestamp              TEXT     NOT NULL,
    pioreactor_unit        TEXT     NOT NULL,
    od_reading_v           REAL     NOT NULL,
    experiment             TEXT     NOT NULL,
    angle                  INTEGER  NOT NULL,
    channel                TEXT CHECK( channel IN ('1', '2')) NOT NULL
);

CREATE INDEX IF NOT EXISTS od_readings_raw_ix
ON od_readings_raw (experiment);


CREATE TABLE IF NOT EXISTS alt_media_fractions (
    timestamp              TEXT  NOT NULL,
    pioreactor_unit        TEXT  NOT NULL,
    alt_media_fraction     REAL  NOT NULL,
    experiment             TEXT  NOT NULL
);

CREATE INDEX IF NOT EXISTS alt_media_fractions_ix
ON alt_media_fractions (experiment);



CREATE TABLE IF NOT EXISTS od_readings_filtered (
    timestamp              TEXT     NOT NULL,
    pioreactor_unit        TEXT     NOT NULL,
    normalized_od_reading  REAL     NOT NULL,
    experiment             TEXT     NOT NULL
);

CREATE INDEX IF NOT EXISTS od_readings_filtered_ix
ON od_readings_filtered (experiment);



CREATE TABLE IF NOT EXISTS dosing_events (
    timestamp              TEXT  NOT NULL,
    experiment             TEXT  NOT NULL,
    event                  TEXT  NOT NULL,
    volume_change_ml       REAL  NOT NULL,
    pioreactor_unit        TEXT  NOT NULL,
    source_of_event        TEXT
);



CREATE TABLE IF NOT EXISTS led_change_events (
    timestamp              TEXT                                       NOT NULL,
    experiment             TEXT                                       NOT NULL,
    channel                TEXT CHECK( channel IN ('A','B','C', 'D')) NOT NULL,
    intensity              REAL                                       NOT NULL,
    pioreactor_unit        TEXT                                       NOT NULL,
    source_of_event        TEXT
);



CREATE TABLE IF NOT EXISTS growth_rates (
    timestamp              TEXT  NOT NULL,
    experiment             TEXT  NOT NULL,
    rate                   REAL  NOT NULL,
    pioreactor_unit        TEXT  NOT NULL
);

CREATE INDEX IF NOT EXISTS growth_rates_ix
ON growth_rates (experiment);



CREATE TABLE IF NOT EXISTS logs (
    timestamp              TEXT  NOT NULL,
    experiment             TEXT  NOT NULL,
    message                TEXT  NOT NULL,
    pioreactor_unit        TEXT  NOT NULL,
    source                 TEXT  NOT NULL,
    level                  TEXT,
    task                   TEXT
);

CREATE INDEX IF NOT EXISTS logs_ix
ON logs (experiment, level, task);



CREATE TABLE IF NOT EXISTS experiments (
    experiment             TEXT  NOT NULL UNIQUE,
    timestamp              TEXT  NOT NULL,
    description            TEXT,
    media_used             TEXT,
    organism_used          TEXT
);

-- since we are almost always calling this like "SELECT * FROM experiments ORDER BY timestamp DESC LIMIT 1",
-- a index on all columns is much faster, BigO(n). This table is critical for the entire webpage performance.
-- not the order of the values in the index is important to get this performance.
-- https://medium.com/@JasonWyatt/squeezing-performance-from-sqlite-indexes-indexes-c4e175f3c346
CREATE INDEX IF NOT EXISTS experiments_ix ON experiments (timestamp, experiment, description);


CREATE VIEW IF NOT EXISTS latest_experiment AS SELECT experiment, timestamp, description, media_used, organism_used, round( (strftime("%s","now") - strftime("%s", timestamp))/60/60, 0) as delta_hours FROM experiments ORDER BY timestamp DESC LIMIT 1;


CREATE TABLE IF NOT EXISTS dosing_automation_settings (
    pioreactor_unit          TEXT  NOT NULL,
    experiment               TEXT  NOT NULL,
    started_at               TEXT  NOT NULL,
    ended_at                 TEXT,
    automation_name          TEXT  NOT NULL,
    settings                 TEXT  NOT NULL
);



CREATE TABLE IF NOT EXISTS led_automation_settings (
    pioreactor_unit          TEXT NOT NULL,
    experiment               TEXT NOT NULL,
    started_at               TEXT NOT NULL,
    ended_at                 TEXT,
    automation_name          TEXT NOT NULL,
    settings                 TEXT NOT NULL
);



CREATE TABLE IF NOT EXISTS temperature_automation_settings (
    pioreactor_unit          TEXT NOT NULL,
    experiment               TEXT NOT NULL,
    started_at               TEXT NOT NULL,
    ended_at                 TEXT,
    automation_name          TEXT NOT NULL,
    settings                 TEXT NOT NULL
);



CREATE TABLE IF NOT EXISTS kalman_filter_outputs (
    timestamp                TEXT NOT NULL,
    pioreactor_unit          TEXT NOT NULL,
    experiment               TEXT NOT NULL,
    state_0                  REAL NOT NULL,
    state_1                  REAL NOT NULL,
    state_2                  REAL NOT NULL,
    cov_00                   REAL NOT NULL,
    cov_01                   REAL NOT NULL,
    cov_02                   REAL NOT NULL,
    cov_11                   REAL NOT NULL,
    cov_12                   REAL NOT NULL,
    cov_22                   REAL NOT NULL
);



CREATE TABLE IF NOT EXISTS temperature_readings (
    timestamp                TEXT  NOT NULL,
    pioreactor_unit          TEXT NOT NULL,
    experiment               TEXT NOT NULL,
    temperature_c            REAL NOT NULL
);


CREATE INDEX IF NOT EXISTS temperature_readings_ix
ON temperature_readings (experiment);



CREATE TABLE IF NOT EXISTS stirring_rates (
    timestamp                TEXT NOT NULL,
    pioreactor_unit          TEXT NOT NULL,
    experiment               TEXT NOT NULL,
    measured_rpm             REAL NOT NULL
);



CREATE TABLE IF NOT EXISTS config_files (
    timestamp                TEXT NOT NULL,
    filename                 TEXT NOT NULL,
    data                     TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS od_blanks (
    timestamp                TEXT NOT NULL,
    pioreactor_unit          TEXT NOT NULL,
    experiment               TEXT NOT NULL,
    channel                  TEXT CHECK( channel IN ('1', '2')) NOT NULL,
    angle                    INTEGER NOT NULL,
    od_reading_v             REAL NOT NULL
);


CREATE TABLE IF NOT EXISTS ir_led_intensities (
    timestamp                TEXT NOT NULL,
    pioreactor_unit          TEXT NOT NULL,
    experiment               TEXT NOT NULL,
    relative_intensity       REAL NOT NULL
);


CREATE TABLE IF NOT EXISTS pioreactor_unit_labels (
    pioreactor_unit          TEXT NOT NULL,
    experiment               TEXT NOT NULL,
    label                    TEXT NOT NULL,
    UNIQUE(pioreactor_unit, experiment)
);

CREATE TABLE IF NOT EXISTS temperature_automation_events (
    pioreactor_unit          TEXT NOT NULL,
    experiment               TEXT NOT NULL,
    event_name               TEXT NOT NULL,
    message                  TEXT,
    data                     TEXT,
    timestamp                TEXT
);

CREATE TABLE IF NOT EXISTS dosing_automation_events (
    pioreactor_unit          TEXT NOT NULL,
    experiment               TEXT NOT NULL,
    event_name               TEXT NOT NULL,
    message                  TEXT,
    data                     TEXT,
    timestamp                TEXT
);

CREATE TABLE IF NOT EXISTS led_automation_events (
    pioreactor_unit          TEXT NOT NULL,
    experiment               TEXT NOT NULL,
    event_name               TEXT NOT NULL,
    message                  TEXT,
    data                     TEXT,
    timestamp                TEXT
);