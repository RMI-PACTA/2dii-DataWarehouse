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
  ticker_symbol TEXT
);

CREATE TRIGGER tg_globaldata_power_extract_company_name
  AFTER INSERT OR UPDATE ON rawdata.globaldata_power_extract
  FOR EACH ROW
  EXECUTE PROCEDURE etl.trigger_update_company_raw('company_name');

CREATE TRIGGER tg_globaldata_power_extract_parent_name
  AFTER INSERT OR UPDATE ON rawdata.globaldata_power_extract
  FOR EACH ROW
  EXECUTE PROCEDURE etl.trigger_update_company_raw('parent_name');

--Power Plants
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

CREATE TRIGGER tg_globaldata_power_plants_operator_name
  AFTER INSERT OR UPDATE ON rawdata.globaldata_power_plants
  FOR EACH ROW
  EXECUTE PROCEDURE etl.trigger_update_company_raw('operator_name');

CREATE TRIGGER tg_globaldata_power_plants_owner_name
  AFTER INSERT OR UPDATE ON rawdata.globaldata_power_plants
  FOR EACH ROW
  EXECUTE PROCEDURE etl.trigger_update_company_raw('owner_name');

--Power Purchase Agreements
CREATE TABLE rawdata.globaldata_power_purchase_agreements (
  id serial PRIMARY KEY,
  import_history_id INT NOT NULL REFERENCES rawdata.import_history(id),
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
  global_reference_id INT
);

CREATE TRIGGER tg_globaldata_power_purchase_agreements_client_company
  AFTER INSERT OR UPDATE ON rawdata.globaldata_power_purchase_agreements
  FOR EACH ROW
  EXECUTE PROCEDURE etl.trigger_update_company_raw('client_company');

CREATE TRIGGER tg_globaldata_power_purchase_agreements_vendor_company
  AFTER INSERT OR UPDATE ON rawdata.globaldata_power_purchase_agreements
  FOR EACH ROW
  EXECUTE PROCEDURE etl.trigger_update_company_raw('vendor_company');
