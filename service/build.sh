#!/bin/bash

rm -rf output/lambdas
mkdir -p output/lambdas

for module in `ls -1 modules`; do
    echo $module
    mkdir -p output/$module
    for lambda in `ls -1 modules/$module/lambdas`; do
        echo === Compiling $lambda for $module ===
        GOOS=linux GOARCH=amd64 go build -o ./output/lambdas/$module/$lambda modules/$module/lambdas/$lambda/*
    done
done

rm -rf output/builds
mkdir -p output/builds

cd output/lambdas
for module in `ls -1`; do
    mkdir -p ../builds/$module

    cd $module
    for lambda in `ls -1`; do
        echo === Packaging $lambda for $module ===
        zip ../../builds/$module/$lambda.zip $lambda
    done
    cd ..
done
