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
  public static String UDP_IP = "192.168.10.1";
  public static int TRAIN_UDP_PORT = 9011;
	public static Hashtable arg;
	DatagramSocket clientSocket;
	InetAddress IPAddress;

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

		try {
      clientSocket = new DatagramSocket();
      this.IPAddress = InetAddress.getByName(UDP_IP);
    }
		catch (Exception e) {
      System.out.println("Error creating UDP socket.");
    }
	}

	public void sendPackets(int[] packet) {
		PCControlMsg payload = new PCControlMsg();
		try {
			payload.set_param(packet);
			moteIF.send(BASE_ID, payload);
		}
		catch (IOException exception) {
			System.err.println(exception);
		}
	}

	public void messageReceived(int to, Message message) {
	}

	public void sendToUDP(String data, int port)
	{
		byte[] sendData = new byte[100];
		sendData = data.getBytes();
		try
		{
			DatagramPacket sendPacket = new 
        DatagramPacket(sendData, sendData.length, this.IPAddress, port);
			this.clientSocket.send(sendPacket);
		}
		catch (Exception e) {System.out.println("Error sending UDP data.");}
	}

  public void do_train(String[] inputs)
  {
    int[] packet = {0, 0, 0, 0, 0, 0};
    Random rnd = new Random();

    while  (true) {
      // Training
      sendToUDP("TRAIN=1", TRAIN_UDP_PORT);
      System.out.println("-----------\nstart training");
      for (int i = 1; i < inputs.length; i++) {
        try {packet[0] = Integer.parseInt(inputs[i]);}
        catch  (Exception e) {continue;}
        packet[1] = (Integer) arg.get("on");
        sendPackets(packet);
        System.out.print(String.format("%d on", packet[0]));

        sleep(40000);

        packet[1] = (Integer) arg.get("off");
        sendPackets(packet);
        System.out.print(String.format("%d off", packet[0]));        

        sleep(20000);
      }
      sendToUDP("TRAIN=2", TRAIN_UDP_PORT);
      System.out.println("stop training");

      // Evaluating
      System.out.println("start evaluating");
      for (int i = 1; i < inputs.length; i++) {
        try {packet[0] = Integer.parseInt(inputs[i]);}
        catch  (Exception e) {continue;}
        if (rnd.nextInt(2) == 0) {
          packet[1] = (Integer) arg.get("on");
          sendPackets(packet);
          System.out.print(String.format("%d ", packet[0]));
        }
      }

      sleep(60000);

      packet[0] = (Integer) arg.get("all");
      packet[1] = (Integer) arg.get("off");
      sendPackets(packet);
      System.out.println("stop evaluating");
    }
  }

  public void do_test(String[] inputs) {
    int length = (int) Math.pow(2, inputs.length-1);
    System.out.println(length);
    int[] packet = {0, 0, 0, 0, 0, 0};
    int state;
    for (int i = 0; i < length; i++) {
      System.out.print(String.format("%d: ", i));
      for (int j = 0; j < inputs.length-1; j++) {
        try {packet[0] = Integer.parseInt(inputs[j+1]);}
        catch  (Exception e) {continue;}
        state = (i>>j) % 2;
        packet[1] = state == 0 ? (Integer) arg.get("off") : (Integer) arg.get("on");
        sendPackets(packet);
        System.out.print(String.format("%d ", state));
      }

      sleep(20000);

      packet[0] = (Integer) arg.get("all");
      packet[1] = (Integer) arg.get("off");
      sendPackets(packet);

      sleep(5000);
    }
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

  public void sleep(int time) {
    int count = time / 1000;
    System.out.println();
    for (int i = 0; i < count; i++) {
      try {
        Thread.sleep(1000);
        System.out.print(".");
      }
      catch (Exception e) {continue;}
    }
    System.out.println();
  }
	public static void main(String[] args) throws Exception
	{
		String source = "serial@/dev/ttyUSB" + args[0] + ":115200";
		PhoenixSource phoenix;

		if (source == null)
			phoenix = BuildSource.makePhoenix(PrintStreamMessenger.err);
					phoenix = BuildSource.makePhoenix(source, PrintStreamMessenger.err);

  	PCComm comm = new PCComm(new MoteIF(phoenix));
		BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

		while (true) {
			System.out.print(">>>");
			String input = br.readLine();
			String[] inputs = input.split(" ");

			if (inputs[0].equals("send"))
				comm.do_send(inputs);
      else if (inputs[0].equals("train"))
				comm.do_train(inputs);
			else if (inputs[0].equals("exit"))
				System.exit(0);
      else if (inputs[0].equals("test"))
				comm.do_test(inputs);
			else if (inputs[0].equals(""))
				continue;
			else
				System.out.println("Command not found");
		}
	}
}
