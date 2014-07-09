public class AddStore4PWithTypeExtension{
    public String displayEdit{get;set;}
    public AddStore4PWithTypeExtension(ApexPages.StandardController controller){
        displayEdit = 'display:none';
    }
    public void test(){
        displayEdit = '';
    }
}