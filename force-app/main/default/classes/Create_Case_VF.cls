public class Create_Case_VF{
    public Case c { get; set; }
    public Create_Case_VF(){
        c = new Case();
    }
    public void save(){
        insert c;
    }
}