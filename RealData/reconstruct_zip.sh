#!/bin/bash

echo "Reconstructing ReadDataBPMSymptoms.zip from parts..."
cat ReadDataBPMSymptoms.zip.part* > ReadDataBPMSymptoms.zip
echo "Done! File reconstructed as ReadDataBPMSymptoms.zip" 