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
	public static int UDP_SPLUG_DATA_PORT = 9000;
	public static int UDP_AMR_DATA_PORT = 9002;
	public static boolean isTraining = false;
	public static String TRAINING_START = "1";
	public static String TRAINING_STOP = "2";
	public static String SPLUG_LOG_FILE = "splug.out";
	public static String AMR_LOG_FILE = "amr.out";
	public static NodeList nodeList;
	DatagramSocket clientSocket;
	InetAddress IPAddress;
	public static Hashtable arg;
    public static int udpCounter;

	public PCComm(MoteIF moteIF, String ipAddr) {
		this.moteIF = moteIF;
		this.moteIF.registerListener(new SPlugDataMsg(), this);
		this.moteIF.registerListener(new AMRDataMsg(), this);
		try {clientSocket = new DatagramSocket();}
		catch (Exception e) {System.out.println("Error creating datagram socket");}
		setip(ipAddr);

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

        udpCounter = 0;
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
        // Current
		short cs[] = msg.get_current();
		int c = cs[0]*65536 + cs[1]*256 + cs[2];
        // Active power
		short ps[] = msg.get_aenergy();
		int p = ps[0]*65536 + ps[1]*256 + ps[2];

        Node node = nodeList.findNode(id);
		if (node == null)
		{
			nodeList.addNode(new Node(id, String.format("Node%d", id)));
			System.out.println(String.format("Node %d discovered", id));
			return;
		}

		node.update(counter, state, c, p);

        String logStr = isTraining ? TRAINING_START : TRAINING_STOP;
        logStr += "," + udpCounter;

		for (int i = 0; i < nodeList.nodeNum;i++)
			if (nodeList.node[i].state == 1)
				logStr += "," + nodeList.node[i].id;
		logStr += "\n";
		sendToUDP(logStr, UDP_SPLUG_DATA_PORT);
	}

	public void processAMRDataMsg(AMRDataMsg msg)
	{
	}

	public void sendToUDP(String data, int port)
	{
		byte[] sendData = new byte[200];
		sendData = data.getBytes();
		try
		{
			DatagramPacket sendPacket = new DatagramPacket(sendData, sendData.length, this.IPAddress, port);
			this.clientSocket.send(sendPacket);
            udpCounter++;
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

    /*	public void do_train(String[] inputs)
	{
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
        }*/

	public void do_setip(String[] inputs)
	{
		if (inputs.length < 2)
		{
			System.out.println("Invalid input");
			return;
		}
		setip(inputs[1]);
		
	}

    public void do_train(String[] inputs)
    {
        int[] onPkt = {0, 4, 0, 0, 0};
        int[] offPkt = {0, 5, 0, 0, 0};
        
        int on, off;
        try {on = Integer.parseInt(inputs[1]);}
		catch (Exception e) {on = 15000;}
        try {off = Integer.parseInt(inputs[1]);}
		catch (Exception e) {off = 5000;}
        
        System.out.println(String.format("On:%dms, Off:%dms", on, off));
        while(true) {
            isTraining = true;
            for (int i = 0; i < nodeList.nodeNum; i++)
            {
                Node node = nodeList.node[i];
                onPkt[0] = node.id;
                offPkt[0] = node.id;
                
                sendPackets(onPkt);
                System.out.println(String.format("%d ON", node.id));
                try {Thread.sleep(on);} 
                catch (Exception e) {}
                
                sendPackets(offPkt);
                System.out.println(String.format("%d OFF", node.id));
                try {Thread.sleep(off);} 
                catch (Exception e) {}
            }
            isTraining = false;

            try {Thread.sleep(15000);}
			catch (Exception e) {}
        }
    }

	public static void main(String[] args) throws Exception
	{
		String source = "serial@/dev/ttyUSB" + args[0] + ":115200";
        //String source = "serial@/tmp/sersock" + ":115200";

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

			//else if (inputs[0].equals("setagg"))
			//	comm.do_setagg(inputs);

			else if (inputs[0].equals("send"))
				comm.do_send(inputs);

			else if (inputs[0].equals("train"))
				comm.do_train(inputs);

			//else if (inputs[0].equals("setip"))
			//	comm.do_setip(inputs);

			else if (inputs[0].equals("exit"))
				System.exit(0);

			else if (inputs[0].equals(""))
				continue;

			else
				System.out.println("Command not found");
		}
	}
}
