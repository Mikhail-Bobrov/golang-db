#!/bin/bash
echo "this script adds access to table in one schema for all users "
echo "or you can skip someone "
echo "choose project name"
read -p "Enter project: " project
echo "(postgres) example"
read -p "Enter database: "  database
namespace='default'
podname="postgres-main-0"
echo "(postgres-main-0) example"
read -p "Enter podname: "  podname

check()
{
    echo "a) Read policy for all user in schema "
    echo "b) Write policy for several users"
    read -p "Choose a \ b : "  userAccess
    kubectl exec -ti -n $namespace $podname  -c postgres -- psql -U postgres -d $database -c '\du' -n  -o  list-of-users.txt
    kubectl cp $namespace/$podname:/home/postgres/list-of-users.txt list-of-users.txt
    if [ $userAccess == "a" ]; then
        read-all
    elif [ $userAccess == "b" ]; then
        write-many
    else 
        echo "dolbaeb shole a ili b najmi"
    fi
}
read-all()
{
    echo "example dwh"
    read -p "Enter schem: "  schem
    y=$(cat list-of-users.txt | wc -l)
    
    for (( i=4; i <=$y-1; i++ ))
    do
        user=$(sed -n "${i}p" list-of-users.txt | awk '{print $1}')
        kubectl exec -ti -n $namespace  $podname -c postgres -- psql -U postgres -d $database -c "GRANT USAGE ON SCHEMA $schem TO $user;"
        kubectl exec -ti -n $namespace  $podname -c postgres -- psql -U postgres -d $database -c "GRANT SELECT ON ALL TABLES IN SCHEMA $schem TO $user;"
        kubectl exec -ti -n $namespace  $podname -c postgres -- psql -U postgres -d $database -c "GRANT SELECT ON ALL SEQUENCES IN SCHEMA $schem TO $user;"
        echo "$user access to schema $schem done"

    done
    read -p "Do you wanna chooce another schem?  yes\no " checker
    if [ $checker == "yes" ]; then
        read-all
    else
        exit $?
    fi

}
write-many()
{
    echo "example dwh\public"
    read -p "Enter schem: "  schem
    echo "How many users to write position"
    read -p "Press the number of users: " number
    for (( i=0; i < $number; i++ ))
    do
        read -p "User name: " user_write
        usernameFromlist=$(cat list-of-users.txt  | grep $user_write | awk '{print $1}')
        echo $usernameFromlist
        kubectl exec -ti -n $namespace  $podname -c postgres -- psql -U postgres -d $database -c "GRANT USAGE ON SCHEMA $schem TO $usernameFromlist;"
        kubectl exec -ti -n $namespace  $podname -c postgres -- psql -U postgres -d $database -c "GRANT SELECT ON ALL TABLES IN SCHEMA $schem TO $usernameFromlist;"
        kubectl exec -ti -n $namespace  $podname -c postgres -- psql -U postgres -d $database -c "GRANT SELECT ON ALL SEQUENCES IN SCHEMA $schem TO $usernameFromlist;"
        kubectl exec -ti -n $namespace  $podname -c postgres -- psql -U postgres -d $database -c "GRANT UPDATE ON ALL TABLES IN SCHEMA $schem TO $usernameFromlist;"
        kubectl exec -ti -n $namespace  $podname -c postgres -- psql -U postgres -d $database -c "GRANT UPDATE ON ALL SEQUENCES IN SCHEMA $schem TO $usernameFromlist;"
        kubectl exec -ti -n $namespace  $podname -c postgres -- psql -U postgres -d $database -c "GRANT INSERT ON ALL TABLES IN SCHEMA $schem TO $usernameFromlist;"
        kubectl exec -ti -n $namespace  $podname -c postgres -- psql -U postgres -d $database -c "GRANT INSERT ON ALL SEQUENCES IN SCHEMA $schem TO $usernameFromlist;"
        echo "Shema $schem WRITE access to $usernameFromlist"
    done
    read -p "Do you wanna chooce another schem?  yes\no " checker
    if [ $checker == "yes" ]; then
        write-many
    else
        exit $?
    fi
}

if [ $project == "name" ]; then
    namespace='default'
    check
elif [ $project == "name" ]; then
    namespace='default'
    check
elif [ $project == "name" ]; then
    namespace='default'
    check
elif [ $project == "preprod-name" ]; then
    namespace='backend'
    check
else
    echo "wrong project"
fi




