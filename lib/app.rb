require 'json'
require 'artii'

def setup_files
    path = File.join(File.dirname(__FILE__), '../data/products.json')
    file = File.read(path)
    $products_hash = JSON.parse(file)
    $report_file = File.new("report.txt", "w+")
end

def ascii_print(word)
	a = Artii::Base.new
	puts a.asciify(word)
	$report_file.puts a.asciify(word)
end

def print_report
	puts "Today's Date:#{Time.now.strftime(" %m/%d/%Y")}"
	$report_file.puts "Today's Date:#{Time.now.strftime(" %m/%d/%Y")}"
	ascii_print("Sales Report")
end

def average(sum, items)
     average = (sum / items).round(2)
end

def write_report(value,option = {})
	if option[:description]
		$report_file.puts "#{option[:description]}#{value}"
		puts "#{option[:description]}#{value}"
		
	else
		$report_file.puts value
		puts value
	end
end

def total_sales(value)
    
    total_sales = value["purchases"].inject(0){|sum,data| sum + data["price"].to_f}
    return total_sales.round(2)
end

def average_discount(item, full_price)
    full_price - (average(total_sales(item), item["purchases"].size))
end

def ave_discount_per(retail_price, average_price)
    (((retail_price - average_price) / retail_price) * 100).round(2)
end

def pruducts_report
	ascii_print("Products")
	$products_hash["items"].each do |item|
		write_report(item["title"])
		write_report ("********************")
		write_report(item["full-price"].to_f, description: "Retail Price: $" )
		write_report(item["purchases"].size, description: "Purchase: ")
		write_report(total_sales(item), description: "Total Sales: $")
        write_report(average(total_sales(item), item["purchases"].size), description: "Average Price: $")
		write_report(average_discount(item, item["full-price"].to_f), description: "Average Discount: $")
		write_report(ave_discount_per(item["full-price"].to_f, average(total_sales(item), item["purchases"].size)),description: "Average Discount Percentage: " )		
		puts " "
		$report_file.puts " "
	end
end

  
def calc_brand_stock(item)
    $total_stock += item["stock"].to_i
end

def  calc_brand_price(item)
    $total_price += item["full-price"].to_f
end

def calc_brand_purchases(item)
    item["purchases"].each do |pur|
        $total_sales += pur["price"].to_f
    end
 end


def calc_brand_data(name)
	  $total_stock = 0
      $total_price = 0
      $total_sales = 0
      by_brand = $products_hash["items"].select {|item| item["brand"] == name }
      $by_brand_size = by_brand.size
      write_report(name)
      write_report("********************")
	  by_brand.each do |item|
        calc_brand_stock(item)
        calc_brand_price(item)
        calc_brand_purchases(item)
      end
      end
      
      
def brand_report
	by_brand = []
	puts ascii_print("Brand")
	brand = $products_hash["items"].map{|item| item["brand"]}.uniq
	brand.each do |name|
		calc_brand_data(name)
      	write_report($total_stock, description: "Number of Products: ")
      	write_report(average($total_price, $by_brand_size), description: "Average Product Price:")
      	write_report($total_sales.round(2), description: "Total Sales:")
      	puts " "
      	$report_file.puts " "
    end
end


def start
	setup_files
	print_report
	pruducts_report
	brand_report
end

start
