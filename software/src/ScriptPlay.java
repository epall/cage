import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;

/**
 * Created by IntelliJ IDEA.
 * User: epall
 * Date: Mar 19, 2010
 * Time: 7:23:23 PM
 * To change this template use File | Settings | File Templates.
 */
public class ScriptPlay {
    public static void main(String[] args) throws Exception {
        ScriptEngineManager manager = new ScriptEngineManager();
        ScriptEngine appleScript = manager.getEngineByName("AppleScript");
        appleScript.eval("open location \"http://www.google.com\"");
        System.out.println(appleScript);
    }
}
