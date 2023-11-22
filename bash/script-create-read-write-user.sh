#!/bin/bash
echo "must be selected right kube-context"
echo "choose project name"
read -p "Enter project: " project
echo "(postgres)"
read -p "Enter database: "  database
#read -p "Enter the rights you want: "  read-write
read -p "Enter username: "  user
namespace='default'
podname="postgres-main-0"
echo "postgres-backend example"
read -p "Enter podname: "  podname
check-user()
{
    x=$(kubectl exec -ti -n $namespace  $podname -c postgres -- psql -U postgres -d $database -c "\du $user" | grep $user | awk '{print $1}')
    if [ $x == $user ]; then
        echo "user exist"
	read -p "change role?  read/write/no " prava
	if [ $prava == "write" ]; then
		give-write-role
	elif
	   [ $prava == "read" ]; then
	        give-read-role
	else
		exit $?
	fi
    else
	read -p "user doesnt exist , create?   yes/no/bug-user " chose
	if [ $chose == "yes" ]; then
		create-user
	elif
	   [ $chose == "bug-user" ]; then
	        echo "user exist!"
		read -p "change role?  read/write/no " readd
		if [ $readd == read ]; then
			give-read-role
	        elif [ $readd == write ]; then
			give-write-role
		else
			exit $?
		fi
	else
                exit $?
	fi	
    fi
}
create-user()
{
    echo "func for user create"
    read -p "Enter pass for user $user " password
    kubectl exec -ti -n $namespace $podname  -c postgres -- psql -U postgres -d $database -c "CREATE USER $user WITH PASSWORD '$password';" 
    check-user 
}
give-write-role()
{
    echo "func for give  write role "
    kubectl exec -ti -n $namespace $podname  -- psql -U postgres -d $database -c '\dn' -n  -o  list-of-schems.txt
    kubectl cp $namespace/$podname:/home/postgres/list-of-schems.txt list-of-schems.txt
    y=$(cat list-of-schems.txt | wc -l)
    echo "$y"
    for (( i=4; i <=$y-2; i++ ))
    do
        x=$(sed -n "${i}p" list-of-schems.txt | awk '{print $1}')
        echo $x
	kubectl exec -ti -n $namespace  $podname -c postgres -- psql -U postgres -d $database -c "GRANT USAGE ON SCHEMA $x TO $user;"
	kubectl exec -ti -n $namespace  $podname -c postgres -- psql -U postgres -d $database -c "GRANT SELECT ON ALL TABLES IN SCHEMA $x TO $user;"
	kubectl exec -ti -n $namespace  $podname -c postgres -- psql -U postgres -d $database -c "GRANT SELECT ON ALL SEQUENCES IN SCHEMA $x TO $user;"
        kubectl exec -ti -n $namespace  $podname -c postgres -- psql -U postgres -d $database -c "GRANT UPDATE ON ALL TABLES IN SCHEMA $x TO $user;"
        kubectl exec -ti -n $namespace  $podname -c postgres -- psql -U postgres -d $database -c "GRANT UPDATE ON ALL SEQUENCES IN SCHEMA $x TO $user;"
        kubectl exec -ti -n $namespace  $podname -c postgres -- psql -U postgres -d $database -c "GRANT INSERT ON ALL TABLES IN SCHEMA $x TO $user;"
        kubectl exec -ti -n $namespace  $podname -c postgres -- psql -U postgres -d $database -c "GRANT INSERT ON ALL SEQUENCES IN SCHEMA $x TO $user;"
	echo "$x WRITE access to $user done"

    done
}
give-read-role()
{
    echo "func for give read role "
    kubectl exec -ti -n $namespace $podname -c postgres -- psql -U postgres -d $database -c '\dn' -n  -o  list-of-schems.txt
    kubectl cp $namespace/$podname:/home/postgres/list-of-schems.txt list-of-schems.txt
    y=$(cat list-of-schems.txt | wc -l)
    echo "$y"
    for (( i=4; i <=$y-2; i++ ))
    do
        x=$(sed -n "${i}p" list-of-schems.txt | awk '{print $1}')
        echo $x
	kubectl exec -ti -n $namespace  $podname -c postgres -- psql -U postgres -d $database -c "GRANT USAGE ON SCHEMA $x TO $user;"
	kubectl exec -ti -n $namespace  $podname -c postgres -- psql -U postgres -d $database -c "GRANT SELECT ON ALL TABLES IN SCHEMA $x TO $user;"
	kubectl exec -ti -n $namespace  $podname -c postgres -- psql -U postgres -d $database -c "GRANT SELECT ON ALL SEQUENCES IN SCHEMA $x TO $user;"
	echo "$x access to $user done"

    done
}
if [ $project == "name" ]; then
    namespace='default'
    check-user
elif [ $project == "name" ]; then
    namespace='default'
    check-user
elif [ $project == "name" ]; then
    namespace='default'
    check-user
elif [ $project == "preprod-name" ]; then
    namespace='backend'
    check-user
else
    echo "wrong project"
fi

