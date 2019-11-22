BEGIN TRANSACTION;

  INSERT INTO PUBLIC.dw_version(major, minor, patch, notes)
  VALUES (
    0, --Major
    1, --Minor
    2, --Patch
    'Create GlobalData tables'
  );

  --Hydro Power Plants
  CREATE TABLE rawdata.globaldata_power_plants (
    id serial PRIMARY KEY,
    import_history_id INT NOT NULL REFERENCES rawdata.import_history(id),
    technology TEXT,
    global_reference_id INT,
    power_plant_id INT,
    power_plant_name TEXT,
    subsidiary_asset_name TEXT,
    fuel_category TEXT,
    primary_fuel TEXT,
    secondary_fuel TEXT,
    region TEXT,
    country TEXT,
    state_or_province TEXT,
    county TEXT,
    city_or_town TEXT,
    total_capacity NUMERIC,
    total_capacity_unit VARCHAR(7) DEFAULT 'MW',
    active_capacity NUMERIC,
    active_capacity_unit VARCHAR(7) DEFAULT 'MW',
    pipeline_capacity NUMERIC,
    pipeline_capacity_unit VARCHAR(7) DEFAULT 'MW',
    discontinued_capacity NUMERIC,
    discontinued_capacity_unit VARCHAR(7) DEFAULT 'MW',
    status TEXT,
    type_of_plant TEXT,
    owner_id INTEGER,
    owner_name TEXT,
    owner_stake_percentage NUMERIC,
    operator_id NUMERIC,
    operator_name TEXT,
    epc_id NUMERIC,
    epc TEXT,
    year_online INTEGER,
    latitude NUMERIC,
    longitude NUMERIC,
    capex_usd NUMERIC, -- Note this needs to be adjusted from "Millions"
    efficiency_percentage NUMERIC,
    capacity_factor TEXT,
    decommissioning_year INTEGER,
    decommissioning_year_status TEXT
  );

  --Power Extract
  CREATE TABLE rawdata.globaldata_power_extract (
    id serial PRIMARY KEY,
    import_history_id INT NOT NULL REFERENCES rawdata.import_history(id),
    cat_id INT,
    company_name TEXT,
    headquarters TEXT,
    company_type TEXT,
    parent_subsidiary TEXT,
    parent_id INT,
    parent_name TEXT,
    stock_exchange TEXT,
    ticker_symbol TEXT,
    disclaimer TEXT
  );

  --Power Purchase Agreements
  CREATE TABLE rawdata.globaldata_power_purchase_agreements (
    id serial PRIMARY KEY,
    import_history_id INT NOT NULL REFERENCES rawdata.import_history(id),
    cover TEXT,
    announcement_date DATE,
    title TEXT,
    client_company TEXT,
    region TEXT,
    country TEXT,
    status TEXT,
    technology TEXT,
    sub_technology TEXT,
    segment TEXT,
    category TEXT,
    contract_award_year INT,
    delivery_start_year INT,
    delivery_end_year INT,
    delivery_period TEXT,
    vendor_company TEXT,
    head_quarter TEXT,
    associated_plant_name TEXT,
    associated_plant_status TEXT,
    associated_plant_capacity NUMERIC,
    associated_plant_capacity_unit VARCHAR(7) DEFAULT 'MW',
    tender_id INT,
    vendor_id INT,
    associated_plant_id INT,
    client_company_id INT,
    global_reference_id INT,
    disclaimer TEXT
  );

COMMIT TRANSACTION;
