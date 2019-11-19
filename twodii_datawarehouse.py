import psycopg2

import twodii_datawarehouse

def main():
    """Main entrypoint for bootstrapping database and importing data files"""
    # This will generate the db connection (from envvars), find current
    # version, run new migrations, and load any data
    pass

if __name__ == '__main__':
    main()
