CREATE TABLE IF NOT EXISTS od_readings_raw (
    experiment               TEXT NOT NULL,
    pioreactor_unit          TEXT NOT NULL,
    timestamp                TEXT NOT NULL,
    od_reading_v             REAL     NOT NULL,
    angle                    INTEGER  NOT NULL,
    channel                  TEXT CHECK( channel IN ('1', '2')) NOT NULL
);

CREATE INDEX IF NOT EXISTS od_readings_raw_ix
ON od_readings_raw (experiment);


CREATE TABLE IF NOT EXISTS alt_media_fractions (
    experiment               TEXT NOT NULL,
    pioreactor_unit          TEXT NOT NULL,
    timestamp                TEXT NOT NULL,
    alt_media_fraction       REAL  NOT NULL
);

CREATE INDEX IF NOT EXISTS alt_media_fractions_ix
ON alt_media_fractions (experiment);



CREATE TABLE IF NOT EXISTS od_readings_filtered (
    experiment               TEXT NOT NULL,
    pioreactor_unit          TEXT NOT NULL,
    timestamp                TEXT NOT NULL,
    normalized_od_reading    REAL NOT NULL
);

CREATE INDEX IF NOT EXISTS od_readings_filtered_ix
ON od_readings_filtered (experiment);



CREATE TABLE IF NOT EXISTS dosing_events (
    experiment               TEXT NOT NULL,
    pioreactor_unit          TEXT NOT NULL,
    timestamp                TEXT NOT NULL,
    event                    TEXT  NOT NULL,
    volume_change_ml         REAL  NOT NULL,
    source_of_event          TEXT
);



CREATE TABLE IF NOT EXISTS led_change_events (
    experiment             TEXT                                       NOT NULL,
    pioreactor_unit        TEXT                                       NOT NULL,
    timestamp              TEXT                                       NOT NULL,
    channel                TEXT CHECK( channel IN ('A','B','C', 'D')) NOT NULL,
    intensity              REAL                                       NOT NULL,
    source_of_event        TEXT
);



CREATE TABLE IF NOT EXISTS growth_rates (
    experiment               TEXT NOT NULL,
    pioreactor_unit          TEXT NOT NULL,
    timestamp                TEXT NOT NULL,
    rate                     REAL  NOT NULL
);

CREATE INDEX IF NOT EXISTS growth_rates_ix
ON growth_rates (experiment);



CREATE TABLE IF NOT EXISTS logs (
    experiment               TEXT NOT NULL,
    pioreactor_unit          TEXT NOT NULL,
    timestamp                TEXT NOT NULL,
    message                  TEXT  NOT NULL,
    source                   TEXT  NOT NULL,
    level                    TEXT,
    task                     TEXT
);

CREATE INDEX IF NOT EXISTS logs_ix
ON logs (experiment, level, task);



CREATE TABLE IF NOT EXISTS experiments (
    experiment             TEXT  NOT NULL UNIQUE,
    created_at             TEXT  NOT NULL,
    description            TEXT,
    media_used             TEXT,
    organism_used          TEXT
);

-- since we are almost always calling this like "SELECT * FROM experiments ORDER BY timestamp DESC LIMIT 1",
-- a index on all columns is much faster, BigO(n). This table is critical for the entire webpage performance.
-- not the order of the values in the index is important to get this performance.
-- https://medium.com/@JasonWyatt/squeezing-performance-from-sqlite-indexes-indexes-c4e175f3c346
CREATE UNIQUE INDEX IF NOT EXISTS experiments_ix ON experiments (created_at, experiment, description);


CREATE VIEW IF NOT EXISTS latest_experiment AS SELECT experiment, created_at, description, media_used, organism_used, round( (strftime("%s","now") - strftime("%s", created_at))/60/60, 0) as delta_hours FROM experiments ORDER BY created_at DESC LIMIT 1;


CREATE TABLE IF NOT EXISTS dosing_automation_settings (
    experiment               TEXT  NOT NULL,
    pioreactor_unit          TEXT  NOT NULL,
    started_at               TEXT  NOT NULL,
    ended_at                 TEXT,
    automation_name          TEXT  NOT NULL,
    settings                 TEXT  NOT NULL
);



CREATE TABLE IF NOT EXISTS led_automation_settings (
    experiment               TEXT NOT NULL,
    pioreactor_unit          TEXT NOT NULL,
    started_at               TEXT NOT NULL,
    ended_at                 TEXT,
    automation_name          TEXT NOT NULL,
    settings                 TEXT NOT NULL
);



CREATE TABLE IF NOT EXISTS temperature_automation_settings (
    experiment               TEXT NOT NULL,
    pioreactor_unit          TEXT NOT NULL,
    started_at               TEXT NOT NULL,
    ended_at                 TEXT,
    automation_name          TEXT NOT NULL,
    settings                 TEXT NOT NULL
);



CREATE TABLE IF NOT EXISTS kalman_filter_outputs (
    experiment               TEXT NOT NULL,
    pioreactor_unit          TEXT NOT NULL,
    timestamp                TEXT NOT NULL,
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
    experiment               TEXT NOT NULL,
    pioreactor_unit          TEXT NOT NULL,
    timestamp                TEXT NOT NULL,
    temperature_c            REAL NOT NULL
);


CREATE INDEX IF NOT EXISTS temperature_readings_ix
ON temperature_readings (experiment);



CREATE TABLE IF NOT EXISTS stirring_rates (
    experiment               TEXT NOT NULL,
    pioreactor_unit          TEXT NOT NULL,
    timestamp                TEXT NOT NULL,
    measured_rpm             REAL NOT NULL
);



CREATE TABLE IF NOT EXISTS config_files_histories (
    timestamp                TEXT NOT NULL,
    filename                 TEXT NOT NULL,
    data                     TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS od_blanks (
    experiment               TEXT NOT NULL,
    pioreactor_unit          TEXT NOT NULL,
    timestamp                TEXT NOT NULL,
    channel                  TEXT CHECK( channel IN ('1', '2')) NOT NULL,
    angle                    INTEGER NOT NULL,
    od_reading_v             REAL NOT NULL
);


CREATE TABLE IF NOT EXISTS ir_led_intensities (
    experiment               TEXT NOT NULL,
    pioreactor_unit          TEXT NOT NULL,
    timestamp                TEXT NOT NULL,
    relative_intensity       REAL NOT NULL
);


CREATE TABLE IF NOT EXISTS pioreactor_unit_labels (
    experiment               TEXT NOT NULL,
    pioreactor_unit          TEXT NOT NULL,
    label                    TEXT NOT NULL,
    created_at               TEXT NOT NULL,
    UNIQUE(pioreactor_unit, experiment)
);

CREATE TABLE IF NOT EXISTS temperature_automation_events (
    experiment               TEXT NOT NULL,
    pioreactor_unit          TEXT NOT NULL,
    timestamp                TEXT NOT NULL,
    event_name               TEXT NOT NULL,
    message                  TEXT,
    data                     TEXT
);

CREATE TABLE IF NOT EXISTS dosing_automation_events (
    experiment               TEXT NOT NULL,
    pioreactor_unit          TEXT NOT NULL,
    timestamp                TEXT NOT NULL,
    event_name               TEXT NOT NULL,
    message                  TEXT,
    data                     TEXT
);

CREATE TABLE IF NOT EXISTS led_automation_events (
    experiment               TEXT NOT NULL,
    pioreactor_unit          TEXT NOT NULL,
    timestamp                TEXT NOT NULL,
    event_name               TEXT NOT NULL,
    message                  TEXT,
    data                     TEXT
);



CREATE TABLE IF NOT EXISTS pioreactor_unit_activity_data (
    experiment               TEXT NOT NULL,
    pioreactor_unit          TEXT NOT NULL,
    timestamp                TEXT NOT NULL,
    od_reading_v             REAL,
    normalized_od_reading    REAL,
    temperature_c            REAL,
    growth_rate              REAL,
    measured_rpm             REAL,
    led_A_intensity_update   REAL,
    led_B_intensity_update   REAL,
    led_C_intensity_update   REAL,
    led_D_intensity_update   REAL,
    add_media_ml             REAL,
    remove_waste_ml          REAL,
    add_alt_media_ml         REAL
);


CREATE UNIQUE INDEX IF NOT EXISTS pioreactor_unit_activity_data_ix
ON pioreactor_unit_activity_data (experiment, pioreactor_unit, timestamp);

