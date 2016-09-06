require "./spec_helper"

describe Query::Builder do
  it "selects * from table" do
    builder = Query::Builder.new
    builder.table("test").get.should eq "SELECT * FROM test LIMIT 1"
  end

  it "sql query" do
    builder = Query::Builder.new
    query = builder.query("SELECT id, title FROM test_table WHERE id = ? AND title = ? ORDER BY id DESC LIMIT 10", [17, "Crystal"])
    query.should eq "SELECT id, title FROM test_table WHERE id = '17' AND title = 'Crystal' ORDER BY id DESC LIMIT 10"
  end

  it "select given fields from table" do
    builder = Query::Builder.new
    query = builder.table("test").select("id, title, content, status").get_all
    query.should eq "SELECT id, title, content, status FROM test"
  end

  it "select functions (max, min, count, sum, avg)" do
    builder = Query::Builder.new
    query = builder.table("test").max("price", "maxPrice").get_all
    query.should eq "SELECT MAX(price) AS maxPrice FROM test"
  end

  it "sql join" do
    builder = Query::Builder.new
    query = builder.table("test").left_join("foo", "test.id", "foo.page_id").get_all
    query.should eq "SELECT * FROM test LEFT JOIN foo ON test.id = foo.page_id"
  end

  it "where and or_where" do
    builder = Query::Builder.new
    query = builder.table("test").where("auth", 1).or_where("auth", 2).get_all
    query.should eq "SELECT * FROM test WHERE auth = '1' OR auth = '2'"
  end

  it "sql where in" do
    builder = Query::Builder.new
    query = builder.table("test").where("active", 1).in("id", [1, 2, 3]).get_all
    query.should eq "SELECT * FROM test WHERE active = '1' AND id IN ('1', '2', '3')"
  end

  it "sql where between" do
    builder = Query::Builder.new
    query = builder.table("test").where("status", 1).between("age", 18, 30).get_all
    query.should eq "SELECT * FROM test WHERE status = '1' AND age BETWEEN '18' AND '30'"
  end

  it "sql where like" do
    builder = Query::Builder.new
    query = builder.table("test").where("status", 1).like("title", "%crystal%").limit(10).get_all
    query.should eq "SELECT * FROM test WHERE status = '1' AND title LIKE '%crystal%' LIMIT 10"
  end

  it "sql group by" do
    builder = Query::Builder.new
    query = builder.table("test").where("status", 1).group_by("cat_id").get_all
    query.should eq "SELECT * FROM test WHERE status = '1' GROUP BY cat_id"
  end

  it "sql having" do
    builder = Query::Builder.new
    query = builder.table("test").where("status", 1).group_by("city").having("COUNT(person)", 100).get_all
    query.should eq "SELECT * FROM test WHERE status = '1' GROUP BY city HAVING COUNT(person) > '100'"
  end

  it "sql order by" do
    builder = Query::Builder.new
    query = builder.table("test").where("active", 1).order_by("id", "desc").limit(5).get_all
    query.should eq "SELECT * FROM test WHERE active = '1' ORDER BY id DESC LIMIT 5"
  end

  it "sql limit" do
    builder = Query::Builder.new
    query = builder.table("test").where("status", 1).limit(10, 20).get_all
    query.should eq "SELECT * FROM test WHERE status = '1' LIMIT 10, 20"
  end

  it "sql delete" do
    builder = Query::Builder.new
    query = builder.table("test").where("id", 17).delete
    query.should eq "DELETE FROM test WHERE id = '17'"
  end

  it "sql delete truncate" do
    builder = Query::Builder.new
    query = builder.table("test").delete
    query.should eq "TRUNCATE TABLE test"
  end
end
