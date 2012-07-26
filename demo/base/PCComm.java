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
	public static int BASE_ID = 40;
	public static int UDP_SPLUG_DATA_PORT = 8000;
	public static int UDP_AMR_DATA_PORT = 8002;
	public static int UDP_CONTROL_PORT = 8001;
	public static boolean isTraining = false;
	public static String TRAINING_START = "1";
	public static String TRAINING_STOP = "2";
	public static String SPLUG_LOG_FILE = "splug.out";
	public static String AMR_LOG_FILE = "amr.out";
	public static NodeList nodeList;
	DatagramSocket clientSocket;
	InetAddress IPAddress;
	public static Hashtable arg;

	public PCComm(MoteIF moteIF, String ipAddr) {
		this.moteIF = moteIF;
		this.moteIF.registerListener(new SPlugDataMsg(), this);
		this.moteIF.registerListener(new AMRDataMsg(), this);
		try {clientSocket = new DatagramSocket();}
		catch (Exception e) {System.out.println("Error creating datagram socket");}
		setip(ipAddr);

		arg = new Hashtable();
		arg.put("all", 			new Integer(65535));
		arg.put("sam", 			new Integer(1));
		arg.put("samperiodic", 	new Integer(2));
		arg.put("samstop", 		new Integer(3));
		arg.put("on", 			new Integer(4));
		arg.put("off", 			new Integer(5));
		arg.put("tog", 			new Integer(6));
		arg.put("togperiodic", 	new Integer(7));
		arg.put("togstop", 		new Integer(8));
		arg.put("amrsam", 		new Integer(9));
		arg.put("amrsamrepeat", new Integer(10));
		arg.put("amrsamstop", 	new Integer(11));
	}

	public void setip(String ipAddr)
	{
		try {this.IPAddress = InetAddress.getByName(ipAddr);}
		catch (Exception e) {System.out.println(String.format("Error setting IP Address to %s", ipAddr));return;}
		System.out.println(String.format("Set IP Address to %s", ipAddr));
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
		if (message.amType() == AMRDataMsg.AM_TYPE)
		{
			AMRDataMsg amrmsg = (AMRDataMsg) message;
			processAMRDataMsg(amrmsg);
		}
		else if (message.amType() == SPlugDataMsg.AM_TYPE)
		{
			SPlugDataMsg splugmsg = (SPlugDataMsg) message;
			processSPlugDataMsg(splugmsg);
		}
	}

	public void processSPlugDataMsg(SPlugDataMsg msg)
	{
		int id = msg.get_nodeID();
		int counter = msg.get_counter();
		int state = msg.get_state();
		short cs[] = msg.get_current();
		int c = cs[0]*65536 + cs[1]*256 + cs[2];
		short ps[] = msg.get_aenergy();
		int p = ps[0]*65536 + ps[1]*256 + ps[2];
		short ss[] = msg.get_vaenergy();
		int s = ss[0]*65536 + ss[1]*256 + ss[2];

        Node node = nodeList.findNode(id);
		if (node == null)
		{
			nodeList.addNode(new Node(id, String.format("Node%d", id)));
			System.out.println(String.format("Node %d discovered", id));
			return;
		}

		node.update(counter, state, c, p, s);

		if (id == nodeList.aggNode) // Aggregate node
		{
            String logStr = String.format("%s,%d,%d,%d,%d", isTraining ? TRAINING_START : TRAINING_STOP, node.counter, node.c, node.p, node.s);
			for (int i = 0; i < nodeList.nodeNum;i++)
				if (nodeList.node[i].id != nodeList.aggNode && nodeList.node[i].state == 1)
					logStr += "," + nodeList.node[i].id;
			logStr += "\n";
			sendToUDP(logStr, UDP_SPLUG_DATA_PORT);
			logToFile(logStr, SPLUG_LOG_FILE);
		}
	}

	public void processAMRDataMsg(AMRDataMsg msg)
	{
		int counter = msg.get_counter();
		int[] current = msg.get_current();
		String logStr = counter + ",";
		for (int i = 0; i < current.length; i++)
			logStr += current[i] + ",";
		logStr += "\n";
		sendToUDP(logStr, UDP_AMR_DATA_PORT);
		logToFile(logStr, AMR_LOG_FILE);
	}

	public void sendToUDP(String data, int port)
	{
		byte[] sendData = new byte[200];
		sendData = data.getBytes();
		try
		{
			DatagramPacket sendPacket = new DatagramPacket(sendData, sendData.length, this.IPAddress, port);
			this.clientSocket.send(sendPacket);
		}
		catch (Exception e){System.out.println(String.format("Send UDP error at port %d", port));}
	}

	public void logToFile(String logStr, String filename)
	{
		try
		{
			File file = new File(filename);
			Writer output = new BufferedWriter(new FileWriter(file, true));
			output.write(logStr);
			output.close();
		}
		catch (IOException ioe) {}
	}

	public void do_discover()
	{
		System.out.println("Discovering all nodes");
		int[] discoverPkt = {(Integer)arg.get("all"), (Integer)arg.get("samperiodic"), 500, 500, 0};
		sendPackets(discoverPkt);
		for (int i = 0; i < 5; i++)
		{
			try {Thread.sleep(1000);} 
			catch (Exception e) {}
		}
		System.out.println("Done");
		nodeList.print();
	}

	public void do_print()
	{
		nodeList.print();
	}

	public void do_setname(String[] inputs)
	{
		int id;
		try {id = Integer.parseInt(inputs[1]);}
		catch (Exception e) {System.out.println("Invalid input"); return;}

		Node node = nodeList.findNode(id);
		if (node == null)
			{System.out.println(String.format("Node %d not found", id)); return;}

		node.name = inputs[2];
		System.out.println(String.format("Set node %d's name to %s", id, inputs[2]));
	}

	public void do_setagg(String[] inputs)
	{
		int id;
		try {id = Integer.parseInt(inputs[1]);}
		catch (Exception e) {System.out.println("Invalid input"); return;}

		if (nodeList.findNode(id) == null)
			{System.out.println(String.format("Node %d not found", id)); return;}

		nodeList.aggNode = id;
		System.out.println(String.format("Set node %d as aggregate node", id));
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
	}

	public void do_train(String[] inputs)
	{
		// Make sure aggNode is set first
		if (nodeList.aggNode ==-1)
			{System.out.println("No aggregate node found.");return;}

		// Make sure aggNode is on and all other nodes are off
		// before the training session
		for (int i = 0; i < nodeList.nodeNum; i++)
		{
			Node node = nodeList.node[i];
			if (node.id == nodeList.aggNode && node.state == 0)
				{System.out.println("Aggregate node must be ON");return;}
			if (node.id != nodeList.aggNode && node.state == 1)
				{System.out.println("Non-aggregate node must be OFF");return;
			}
		}

		int id;
		try {id = Integer.parseInt(inputs[1]);}
		catch (Exception e)
		{System.out.println("Invalid input");return;}

		if (nodeList.findNode(id) == null)
			{System.out.println(String.format("Node %d not found", id));return;}

		isTraining = true;
		System.out.println(String.format("Training node %d", id));
		int[] togPkt = {id, (Integer)arg.get("tog"), 0, 0, 0};
                for (int i = 0; i < 10000; i++)
		{
			sendPackets(togPkt);
			System.out.print(String.format("%d/%d", i+1, 4));
			for (int j = 0; j < 8; j++)
			{
				try {Thread.sleep(1000);} 
				catch (Exception e) {}
				System.out.print(".");
			}
			System.out.println();
		}
		System.out.println("Done");
		isTraining = false;
	}

	public void do_setip(String[] inputs)
	{
		if (inputs.length < 2)
		{
			System.out.println("Invalid input");
			return;
		}
		setip(inputs[1]);
		
	}

    public void do_test()
    {
        int[] on53 = {53, 4, 0, 0, 0};
        int[] off53 = {53, 5, 0, 0, 0};
        int[] on54 = {54, 4, 0, 0, 0};
        int[] off54 = {54, 5, 0, 0, 0};
        
        while(true) {
            isTraining = true;
            sendPackets(on53);
            try {Thread.sleep(15000);} 
			catch (Exception e) {}
            sendPackets(off53);
            try {Thread.sleep(5000);} 
			catch (Exception e) {}

            sendPackets(on54);
            try {Thread.sleep(15000);} 
			catch (Exception e) {}
            sendPackets(off54);
            try {Thread.sleep(5000);}
			catch (Exception e) {}
            isTraining = false;

            try {Thread.sleep(15000);}
			catch (Exception e) {}
        }
    }

	public static void main(String[] args) throws Exception
	{
		String source = "serial@/dev/ttyUSB" + args[0] + ":115200";

		PhoenixSource phoenix;

		if (source == null)
			phoenix = BuildSource.makePhoenix(PrintStreamMessenger.err);
		else
			phoenix = BuildSource.makePhoenix(source, PrintStreamMessenger.err);

        // 192.168.0.163
		PCComm comm = new PCComm(new MoteIF(phoenix), "localhost");

		comm.nodeList = new NodeList(10);
		
		BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

		while (true) {
			System.out.print(">>>");
			String input = br.readLine();
			String[] inputs = input.split(" ");

			if (inputs[0].equals("discover"))
				comm.do_discover();

			else if (inputs[0].equals("print"))
				comm.do_print();

			else if (inputs[0].equals("setname"))
				comm.do_setname(inputs);

			else if (inputs[0].equals("setagg"))
				comm.do_setagg(inputs);

			else if (inputs[0].equals("send"))
				comm.do_send(inputs);

			else if (inputs[0].equals("train"))
				comm.do_train(inputs);

			else if (inputs[0].equals("setip"))
				comm.do_setip(inputs);

			else if (inputs[0].equals("exit"))
				System.exit(0);

            else if (inputs[0].equals("test"))
                comm.do_test();

			else if (inputs[0].equals(""))
				continue;

			else
				System.out.println("Command not found");
		}
	}
}
