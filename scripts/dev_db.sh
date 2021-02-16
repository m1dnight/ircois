
#!/bin/bash
# Runs a local instance of postgres to use as development database. 

# Set parameters for database (this should match config/dev.exs)
username=postgres
password=postgres
database=ircois_dev
timezone='Europe/Brussels'
localdata=$(mktemp -d)

# Parameters for network 
network=ircoisnet

# Remove old containers if they are present.
docker rm -f $database 
docker rm -f pg-tmp

# Remove and restart the network.
docker network rm $network 
docker network create $network 

# Run the database 
echo "Running database.."
docker run --rm                                     \
           -d                                       \
           --name $database                         \
           --net=$network                           \
           -e POSTGRES_PASSWORD=postgres            \
           -e TZ=$timezone                          \
           -p 5432:5432                             \
           -v ${localdata}:/var/lib/postgresql/data \
           postgres:13

           
sleep 5s          

# Create the database.
docker run --rm                   \
           --name pg-tmp          \
           --net=$network         \
           -e PGPASSWORD=postgres \
           postgres:13            \
           psql -h $database -U postgres -c "CREATE DATABASE ${database} OWNER ${username};"