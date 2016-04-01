/* What        : A helper class for trigger with reusable functions
   When        : Nov 2015
   Who         : Vishal Khanna 
*/
public class TriggerHelper {
    private static boolean run = true;
    public static Boolean flag = true;
    public static boolean runOnce(){
            if(run){
                run=false;
                return true;
            }
            else{
                return run;
            }
        }
}