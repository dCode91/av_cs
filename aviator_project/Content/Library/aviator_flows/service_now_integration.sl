namespace: aviator_flows
flow:
  name: service_now_integration
  workflow:
    - run_command:
        do:
          io.cloudslang.base.cmd.run_command:
            - command: restart tomcat
        navigate:
          - SUCCESS: get_time
          - FAILURE: on_failure
    - get_time:
        do:
          io.cloudslang.base.datetime.get_time: []
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      run_command:
        x: 160
        'y': 200
      get_time:
        x: 440
        'y': 200
        navigate:
          d60c4f4f-82df-cc16-2da4-17f41b653ae0:
            targetId: c95f208b-7a5b-ce91-db89-c38fb6fe2860
            port: SUCCESS
    results:
      SUCCESS:
        c95f208b-7a5b-ce91-db89-c38fb6fe2860:
          x: 680
          'y': 280
