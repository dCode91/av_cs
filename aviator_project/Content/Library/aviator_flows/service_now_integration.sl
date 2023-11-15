namespace: io.cloudslang.servicenow

imports:
  http: io.cloudslang.base.network.http

flow:
  name: get_servicenow_incident
  inputs:
    - instance_name: "your_instance" # Replace with your ServiceNow instance name
    - username: "your_username"      # Replace with your ServiceNow username
    - password: "your_password"      # Replace with your ServiceNow password
    - incident_number:              # Replace with the incident number you want to fetch

  workflow:
    - get_incident:
        do:
          http.get:
            - url: "'https://' + instance_name + '.service-now.com/api/now/table/incident?sysparm_query=number=' + incident_number"
            - auth_type: "basic"
            - username: username
            - password: password
            - headers: "'Accept:application/json'"
            - connect_timeout: 10000
            - socket_timeout: 10000
            - response_headers_name: "response_headers"
            - status_code: 200

        publish:
          - result: "${get_incident[return_result]}"
          - response_code: "${get_incident[status_code]}"
          - response_headers: "${get_incident[response_headers]}"

        navigate:
          - SUCCESS: on_success
          - FAILURE: on_failure

  results:
    - SUCCESS
    - FAILURE

  outputs:
    - result
    - response_code
    - response_headers
