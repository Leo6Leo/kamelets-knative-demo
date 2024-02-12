/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements. See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import org.apache.camel.spi.DataType

// camel-k: language=groovy
// camel-k: config=secret:aws-s3-credentials

from("kamelet:aws-s3-source?" +
        "bucketNameOrArn={{aws.s3.bucketNameOrArn}}&" +
        "accessKey={{aws.s3.accessKey}}&" +
        "secretKey={{aws.s3.secretKey}}&" +
        "region={{aws.s3.region}}")
        .transform(new DataType("aws2-s3:application-cloudevents"))
        .split(body().tokenize("\n"))
        .filter(simple('${body} != ""'))
        .setBody()
            .simple('{ "client": "aws-s3", "message": "${body}" }')
        .to("log:info")
        .transform(new DataType("http:application-cloudevents"))
        .to("knative:event/org.apache.camel.event.messages?kind=Broker&name=default")
