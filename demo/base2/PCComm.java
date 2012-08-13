import java.io.IOException;
import java.util.*;
import java.io.*;
import java.net.*;

import java.lang.String;
import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;

public class PCComm implements MessageListener {

	private MoteIF moteIF;
	public static int PACKET_SIZE = 6;
	public static int BASE_ID = 20;
	public static boolean isTraining = false;
	public static Hashtable arg;

	public PCComm(MoteIF moteIF) {
		this.moteIF = moteIF;

		arg = new Hashtable();
		arg.put("all", new Integer(65535));
		arg.put("sam", new Integer(1));
		arg.put("samperiodic", new Integer(2));
		arg.put("samstop", new Integer(3));
		arg.put("on", new Integer(4));
		arg.put("off", new Integer(5));
		arg.put("tog", new Integer(6));
		arg.put("togperiodic", new Integer(7));
		arg.put("togstop", new Integer(8));
		arg.put("amrsam", new Integer(9));
		arg.put("samrepeat", new Integer(10));
	}

	public void sendPackets(int[] packet) {
		PCControlMsg payload = new PCControlMsg();
		try {
			payload.set_param(packet);
			moteIF.send(BASE_ID, payload);
		}
		catch (IOException exception) {
			System.err.println("Exception thrown when sending packets. Exiting.");
			System.err.println(exception);
		}
	}

	public void messageReceived(int to, Message message) {
	}

	public void do_send(String[] inputs)
	{
		if (inputs.length == 2)
			{System.out.println("Invalid input"); return;}

		// Convert to integer array
		int[] _inputs = new int[inputs.length-1];
		for (int i = 0; i < _inputs.length; i++)
		{
			if (arg.get(inputs[i+1]) != null)
				_inputs[i] = (Integer) arg.get(inputs[i+1]);
			else
			{
				try {_inputs[i] = Integer.parseInt(inputs[i+1]);}
				catch (Exception e) {System.out.println("Invalid input"); return;}
			}
		}

		// Contruct and send packet
		int[] packet = new int[PCComm.PACKET_SIZE];
		for (int i = 0; i < PCComm.PACKET_SIZE; i++)
			packet[i] = (i < _inputs.length) ?_inputs[i] : 0;
		sendPackets(packet);
    for (int i = 0; i < PCComm.PACKET_SIZE; i++)
      System.out.print(packet[i]+" ");
    System.out.println();
	}

	public static void main(String[] args) throws Exception
	{
		String source = "serial@/dev/ttyUSB" + args[0] + ":115200";
		PhoenixSource phoenix;

		if (source == null)
			phoenix = BuildSource.makePhoenix(PrintStreamMessenger.err);
		else
			phoenix = BuildSource.makePhoenix(source, PrintStreamMessenger.err);

  	PCComm comm = new PCComm(new MoteIF(phoenix));
		BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

		while (true) {
			System.out.print(">>>");
			String input = br.readLine();
			String[] inputs = input.split(" ");

			if (inputs[0].equals("send"))
				comm.do_send(inputs);
			else if (inputs[0].equals("exit"))
				System.exit(0);
			else if (inputs[0].equals(""))
				continue;
			else
				System.out.println("Command not found");
		}
	}
}
