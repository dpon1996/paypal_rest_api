class PrintString{
  final data;
  final bool isDebugMode;

  PrintString(this.data, {this.isDebugMode = false}){
    if(isDebugMode){
      printString(data);
    }
  }
  void printString(data){
    print(data);
  }
}