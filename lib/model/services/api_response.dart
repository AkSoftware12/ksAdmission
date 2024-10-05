enum Status {loading, complete, error}

class ApiResponse<T>{
  Status? status;

  T? data;

  String? message;

  ApiResponse(this.status, this.data, this.message);

  ApiResponse.loading(): status = Status.loading;
  ApiResponse.complete(this.data) : status = Status.complete;
  ApiResponse.error(this.message): status = Status.error;


  @override
  String toString(){
    return "Status: $status\n Message: $message \n Data: $data";
  }
}