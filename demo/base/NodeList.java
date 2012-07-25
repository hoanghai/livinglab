import java.io.IOException;
import java.util.*;
import java.io.*;
import java.lang.String;

class Node
{
    public final double POWER_COEFF1 = 0.229965;
    public final double POWER_COEFF2 = 1.039426;

	public int id;
	public String name;
	public int counter;
	public int state;
	public int val;
    public int lastval;
    public long lastts;

	public Node(int id, String name, int counter, int state, int currval)
	{
		this.id = id;
		this.name = name;
        this.counter = counter;
        this.state = state;
        this.lastval = currval;
        this.lastts = System.currentTimeMillis();
        this.val = 0;
	}
	
	public void update(int counter, int state, int currval)
	{
		this.counter = counter;
		this.state = state;
		this.val = convert(currval);
	}

    private int convert(int currval)
    {
        long currts = System.currentTimeMillis();
        if (currts == lastts)
            return 0;
        int elapsedTime = (int)(currts - lastts);
        int power = 1000 * (currval - lastval) / elapsedTime;
        lastts = currts;
        lastval = currval;
        return (int) (POWER_COEFF1 * power + POWER_COEFF2);
    }
}

public class NodeList
{
	public int max;
	public int nodeNum;
	public Node[] node;
	public int aggNode;

	public NodeList(int max)
	{
		this.max = max;
		this.node = new Node[max];
		this.nodeNum = 0;
		this.aggNode = -1;
	}

	public void addNode(Node newNode)
	{
		if (nodeNum < max)
			node[nodeNum++] = newNode;
	}

	public int findIdx(int id)
	{
		int idx;
		for (idx = 0; idx < nodeNum; idx++)
			if (id == node[idx].id)
				return idx;
		return -1;
	}
	
	public Node findNode(int id)
	{
		int idx = findIdx(id);
		if (idx == -1)
			return null;
		else
			return node[idx];
	}

	void print()
	{
		System.out.println(String.format("%-4s %-10s %-10s %-10s %-10s", "ID", "Name", "Counter", "State", "Current"));
		for (int i = 0; i < nodeNum; i++)
		{
			String tmp = node[i].id == aggNode ? "*" : "";
			System.out.println(String.format("%-4d %-10s %-10d %-10d %-10d", node[i].id, node[i].name+tmp, node[i].counter, node[i].state, node[i].val));
		}
	}
}
