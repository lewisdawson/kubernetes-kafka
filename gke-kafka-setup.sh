#!/usr/bin/env bash

WORKING_DIR="$( dirname "$( readlink "${BASH_SOURCE[0]}" )" )"

echo "Creating 'kafka' namespace..."
kubectl apply -f 00-namespace.yml

echo "\nConfiguring storage classes..."
pushd ./configure/ > /dev/null
kubectl apply -f gke-storageclass-broker-pd.yml
kubectl apply -f gke-storageclass-zookeeper-ssd.yml
popd > /dev/null

echo "\nConfiguring rbac..."
kubectl apply -f ./rbac-namespace-default/

echo "\nConfiguring zookeeper..."
kubectl apply -f ./zookeeper/
echo "Sleeping for 30 seconds while zookeeper starts..."
sleep 30

echo "\nConfiguring kafka..."
kubectl apply -f ./kafka/
echo "Sleeping for 30 seconds while kafka starts..."
sleep 30

echo "\nConfiguring avro tools..."
pushd ./avro-tools/ > /dev/null
kubectl apply -f avro-tools-config.yml

echo "Configuring schema registry..."
kubectl apply -f schemas.yml
kubectl apply -f schemas-service.yml
echo "Sleeping for 30 seconds while schema registry starts..."
sleep 30

echo "Configuring connect..."
kubectl apply -f connect.yml
kubectl apply -f connect-service.yml
popd > /dev/null

echo "Done."
