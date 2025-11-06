#!/bin/bash
conda activate mitogex
java --module-path lib --add-modules javafx.web,javafx.controls,javafx.fxml,javafx.graphics,javafx.base,javafx.swing -jar MitoGEx-1.0.jar  
