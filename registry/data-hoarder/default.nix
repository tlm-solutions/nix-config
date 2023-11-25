rec {
  redis-bureaucrat-lizard = {
    host = "127.0.0.1";
    port = 5314;
  };

  grpc-chemo-bureaucrat = {
    host = "127.0.0.1";
    port = 50056;
  };

  grpc-chemo-funnel = {
    host = "127.0.0.1";
    port = 50052;
  };

  grpc-data_accumulator-chemo = {
    host = "127.0.0.1";
    port = 50053;
  };

  grpc-trekkie-chemo = grpc-data_accumulator-chemo;

  port-data_accumulator = {
    host = "0.0.0.0";
    port = 8080;
  };

  port-datacare = {
    host = "127.0.0.1";
    port = 8070;
  };

  port-lizard = {
    host = "127.0.0.1";
    port = 9001;
  };

  port-funnel = {
    host = "127.0.0.1";
    port = 9002;
  };

  port-funnel-metrics = { port = 10012; };

  port-trekkie = {
    host = "0.0.0.0";
    port = 8060;
  };

  redis-trekkie = {
    host = "localhost";
    port = 6379;
  };
}
