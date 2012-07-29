import java.io.IOException;
import java.util.*;
import java.io.*;
import java.lang.String;

class Node
{
    public final double P1 = 0.229965;
    public final double P2 = 1.039426;

	public int id;
	public String name;
	public int counter;
	public int state;
    public int c, p;

    private int lastp, lasts;
    private long lastts;

	public Node(int id, String name)
	{
		this.id = id;
		this.name = name;
        this.counter = counter;
        this.state = state;
        this.c = 0;
        this.p = 0;

        this.lastp = 0;
        this.lastts = System.currentTimeMillis();
	}
	
	public void update(int counter, int state, int c, int p)
	{
		this.counter = counter;
		this.state = state;
        this.c = c;
		long ts = System.currentTimeMillis();
		if (ts == lastts)
            return;
		this.p = convertPower(p, ts, this.lastp, this.lastts, P1, P2);
		lastp = p;
		lastts = ts;
	}

    private int convertPower(int val, long ts, int lastval, long lastts, double const1, double const2)
    {
        int tmp = (int)(1000 * (val - lastval) / (ts - lastts));
        return (int) (const1 * tmp + const2);
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
		System.out.println(String.format("%-4s %-10s %-10s %-10s %-10s %-10s", "ID", "Name", "Counter", "State", "Current", "Power"));
		for (int i = 0; i < nodeNum; i++)
		{
			String tmp = node[i].id == aggNode ? "*" : "";
			System.out.println(String.format("%-4d %-10s %-10d %-10d %-10d %-10d", node[i].id, node[i].name+tmp, node[i].counter, node[i].state, node[i].c, node[i].p));
		}
	}
}
