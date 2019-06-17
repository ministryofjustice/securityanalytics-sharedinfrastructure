import boto3
import datetime
import time
from colorama import init, Fore, Back, Style

timestamp = {}
g_timestamp = 0


def get_log(client, group):

    global timestamp
    global g_timestamp
    # //, limit=5
    response = client.describe_log_streams(
        logGroupName=group, descending=True
    )
    time.sleep(0.4)
    for streamrec in response['logStreams']:
        stream = streamrec['logStreamName']
        key = f"{group}"
        if key in timestamp.keys():
            response = client.get_log_events(
                logGroupName=group, logStreamName=stream, startTime=timestamp[key]+1
            )
        else:

            response = client.get_log_events(
                logGroupName=group, logStreamName=stream, limit=10, startTime=g_timestamp+1
            )
        if key not in timestamp.keys():
            timestamp[key] = g_timestamp

        for x in response['events']:
            if x['timestamp'] > timestamp[key]:
                timestamp[key] = x['timestamp']
            tstr = datetime.datetime.fromtimestamp(x['timestamp']/1000).strftime('%Y-%m-%d %H:%M:%S')
            msg = x['message'].replace('\n', '')
            msg = (msg[:160] + '...') if len(msg) > 160 else msg
            header = group.replace(f'/aws/lambda/{prefix}-', '')
            # print(f"{tstr} {Fore.RED}{header}{Style.RESET_ALL} {msg}")
            print(f"{tstr} {header} {msg}")


session = boto3.session.Session(profile_name='sec-an')
client = session.client('logs')
prefix = 'mamos-sec-an'
stream_list = [f'/aws/lambda/{prefix}-analytics-ingestor',
               f'/aws/lambda/{prefix}-delay-notify-glue',
               f'/aws/lambda/{prefix}-ingest-dns',
               f'/aws/lambda/{prefix}-nmap-results-parser',
               f'/aws/lambda/{prefix}-nmap-task-q-consumer',
               f'/aws/lambda/{prefix}-scan-initiator',
               f'/aws/lambda/{prefix}-ssl-results-parser',
               f'/aws/lambda/{prefix}-ssl-sns-listener',
               f'/aws/lambda/{prefix}-ssl-task-q-consumer',
               f'/aws/lambda/{prefix}-simple-lambda-sns-listener',
               f'/aws/lambda/{prefix}-simple-lambda-task-q-consumer',
               f'/aws/lambda/{prefix}-simple-lambda-results-parser'
               ]
#    '/aws/lambda/{prefix}-simple-lambda-results-parser',
#
# silence streams (useful if something is broken in the chain):
silence = [f'/aws/lambda/{prefix}-delay-notify-glue',
           f'/aws/lambda/{prefix}-analytics-ingestor',
           f'/aws/lambda/{prefix}-ssl-results-parser',
           f'/aws/lambda/{prefix}-ssl-sns-listener',
           f'/aws/lambda/{prefix}-ssl-task-q-consumer',
           f'/aws/lambda/{prefix}-simple-lambda-sns-listener',
           f'/aws/lambda/{prefix}-simple-lambda-task-q-consumer',
           f'/aws/lambda/{prefix}-simple-lambda-results-parser']
for s in silence:
    stream_list.remove(s)
dt_obj = datetime.datetime.now()
g_timestamp = int(dt_obj.timestamp() * 1000)
while True:
    for stream in stream_list:

        get_log(client, stream)
        time.sleep(0.2)
