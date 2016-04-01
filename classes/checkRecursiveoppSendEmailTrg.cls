/**
    What    : Apex Class to avoid recursive calling of trigger oppSendEmailTrg.
    Who     : Vishal Khanna
    Which   : Version 1.0
    When    : Jan 2016
**/
public Class checkRecursiveoppSendEmailTrg
{
    public static boolean run = true;
    public static boolean runOnce()
    {
        if(run)
        {
             run=false;
             return true;
        }
        else
        {
            return run;
        }
    }
}