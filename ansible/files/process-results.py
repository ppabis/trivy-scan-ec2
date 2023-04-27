#!/usr/bin/env python3
import boto3, json, sys
from datetime import datetime as dt

def upload_to_s3(key, data):
  s3 = boto3.resource('s3')
  key = dt.now().strftime("%Y-%m-%d/") + key
  s3.Object('trivy-results-bucket', key).put(Body=data)
  # Change this bucket name to yours

# Sums up the number of vulnerabilities by severity
def sum_results(json_data):
  severities = {}
  if 'Results' in json_data:
    for result in json_data['Results']:
      if 'Vulnerabilities' in result:
        for vuln in result['Vulnerabilities']:
          if vuln['Severity'] in severities:
            severities[vuln['Severity']] += 1
          else:
            severities[vuln['Severity']] = 1
  return severities


def put_to_cloudwatch(results, artifact_name):
  cloudwatch = boto3.client('cloudwatch')
  for k in results:
    cloudwatch.put_metric_data(
      Namespace='TrivyScan', # Change namespace to yours
      MetricData=[ {
          'MetricName': f"{k}_Vulnerabilities",
          'Unit': "Count",
          'Dimensions': [ {'Name': 'ArtifactName', 'Value': artifact_name} ],
          'Value': results[k]
        } ]
    )

if __name__ == '__main__':
  with open(sys.argv[1], "rb") as f:
    data = f.read()
    json_data = json.loads(data.decode('utf-8'))
    artifact_name = json_data['ArtifactName']
    upload_to_s3( f"{artifact_name}.json", data )
    put_to_cloudwatch( sum_results(json_data), artifact_name )