require 'sinatra'
require 'csv'

get '/MarketDashboard' do
    
  dataUsed = []
  dateUsed = []
  ticketUsed = []
  basePriceUsed = []
      
    
  CSV.foreach('source.csv').each_with_index do |row,i|
    if ($. == 6) | ($. == 8) | ($. == 10)
      dataUsed << row
      dateUsed << row[0]
      ticketUsed << row[1] << row[8] << row[15] << row[22] << row[29] << row[36]
    end
  end
  
  ticketUsed = ticketUsed.uniq{|a| a}.compact
  
  N = dataUsed.length
     
  [*0..(N-1)].each do |m|
    basePriceUsed_ = []
    [3,10,17,24,31,38].each do |n|
      bid = dataUsed[m][n].to_f
      ask = dataUsed[m][n+1].to_f
      last = dataUsed[m][n+3].to_f
          
      if (bid > 0) & (ask >0)
        basePriceUsed_.push(((bid+ask)/2).round(2))
      elsif (last>0)
        basePriceUsed_.push(last.round(2))
      elsif (bid>0)
        basePriceUsed_.push(bid.round(2))
      elsif (ask>0)
        basePriceUsed_.push(ask.round(2))
      else
        basePriceUsed_.push('NA')
      end
    end
    basePriceUsed.push(basePriceUsed_)     
  end
          
  NbasePriceUsed = basePriceUsed.length
      
  resultReturn = []
     
  [*1..(NbasePriceUsed-1)].each do |m|
    resultReturn << basePriceUsed[0].zip(basePriceUsed[m]).collect{|x,y| 
      if(x =="NA") | (y =="NA") 
        "NA" 
      else 
        ((y/x-1)*100).round(1) 
      end }.to_a   
  end
  
    
  @tableDisplay = []
  @tableDisplay << ["",
                    "D-1@" + dateUsed[0][11..15],
                    "D@" + dateUsed[1][11..15],
                    "D@" + dateUsed[1][11..15] + " %",
                    "D@" + dateUsed[2][11..15],
                    "D@" + dateUsed[2][11..15] + " %"
                   ]
                   
  NticketUsed = ticketUsed.length
  
  [*0..(NticketUsed-1)].each do |m|                
    @tableDisplay << [ticketUsed[m], 
                      !(basePriceUsed[0][m] == "NA")? sprintf('%.2f', basePriceUsed[0][m]) : "NA",
                      !(basePriceUsed[1][m] == "NA")? sprintf('%.2f', basePriceUsed[1][m]) : "NA",
                      !(resultReturn[0][m] == "NA")? resultReturn[0][m].to_s + "%" : "NA",
                      !(basePriceUsed[2][m] == "NA")? sprintf('%.2f', basePriceUsed[2][m]) : "NA",
                      !(resultReturn[1][m] == "NA")? resultReturn[1][m].to_s + "%" : "NA"]
  end
                      
                      
  erb :MarketDashboard
end