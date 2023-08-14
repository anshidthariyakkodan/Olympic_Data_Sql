create table olympics_history(
	ID int,
    Name varchar,
    Sex varchar,
    Age varchar,
    Height varchar,
    Weight varchar,
    Team varchar,
    NOC varchar,
    Games varchar,
    Year int,
    Season varchar,
    City varchar,
    Sport varchar,
    Event varchar,
    Medal varchar
    )
	select count(*) from olympics_history
	
create table noc_details(
			noc varchar,
			region varchar,
			notes varchar)
			