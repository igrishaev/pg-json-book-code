

BaseConnection pgConn = (BaseConnection) conn.unwrap(BaseConnection.class);

CopyManager copyManager = new CopyManager(pgConn);

String sql = "COPY (select ...) TO STDOUT WITH (FORMAT CSV, HEADER, DELIMITER ',')";

try (FileOutputStream out = new FileOutputStream("/path/to/file.csv")) {
    long rows = copyManager.copyOut(sql, out);
    System.out.println("Rows exported: ", rows);
}

// GZIPOutputStream
