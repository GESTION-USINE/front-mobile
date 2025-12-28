class DeleteResponse {
  final int id;
  final bool deleted;
  

  DeleteResponse({
    required this.id,
    required this.deleted,
  });

  factory DeleteResponse.fromJson(Map<String, dynamic> json) {
    
 

    return DeleteResponse(
      id: json['id'] as int,
      deleted: json['deleted'] as bool,
    );
  }


   factory DeleteResponse.fromStatus(int status) {
    
    if (status == 200 ) {
      return DeleteResponse(
        id: 0,
        deleted: true,
      );
    } else{
      return DeleteResponse(
        id: 0,
        deleted: false,
      );
    }

    
  }
}
