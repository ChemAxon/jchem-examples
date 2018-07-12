package com.chemaxon.test.helper;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.util.List;
import java.util.stream.Collectors;

public class PrintCollector {

	private final ByteArrayOutputStream bOut;
	private final ByteArrayOutputStream bErr;
	private final PrintStream out;
	private final PrintStream err;

	public PrintCollector() {
		bOut = new ByteArrayOutputStream();
		bErr = new ByteArrayOutputStream();
		out = new PrintStream(bOut);
		err = new PrintStream(bErr);
	}

	public PrintStream getOutStream() {
		return out;
	}

	public PrintStream getErrorStream() {
		return err;
	}

	public List<String> getOutputLines() {
		return getLines(bOut);
	}

	public List<String> getErrorLines() {
		return getLines(bErr);
	}

	private List<String> getLines(ByteArrayOutputStream baos) {
		try (BufferedReader br = new BufferedReader(
				new InputStreamReader(new ByteArrayInputStream(baos.toByteArray())))) {
			return br.lines().collect(Collectors.toList());
		} catch (IOException e) {
			throw new IllegalStateException("can not read data", e);
		}
	}

}
