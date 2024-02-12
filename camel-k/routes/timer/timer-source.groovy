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

client = "timer-source"
message = "Hello from timer-source!"

period = 3000

json = "{ \"client\": \"${client}\", \"message\": \"${message}\" }"

from("kamelet:timer-source?period=${period}&message=${json}&contentType=application/json")
        .to("log:info")
        .transform(new DataType("http:application-cloudevents"))
        .to("knative:event/org.apache.camel.event.messages?kind=Broker&name=default")
