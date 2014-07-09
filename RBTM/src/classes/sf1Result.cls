global class sf1Result {
    public Boolean isSuccess { get; set; }
    public String message { get; set; }
    public String recordID { get; set; }
    
    public sf1Result(Exception ex) {
        this();
        isSuccess = false;
        message = 'Apex Exception: ' + ex.getStackTraceString() + ' : ' + ex.getMessage();
    }

    public sf1Result(ID recordID) {
        this();
        isSuccess = true;
        message = 'Apex completed succesfully';     
        this.recordID = recordID;   
    }
    
    private sf1Result() {}
}