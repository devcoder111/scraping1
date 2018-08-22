import os
import sys
import requests
import schedule
import time
import threading
import csv
from selenium import webdriver
from bs4 import BeautifulSoup
from selenium.webdriver.support.ui import WebDriverWait
from time import gmtime, strftime

from datetime import datetime
from pytz import timezone

def main():	
	if(check_curtime()):
		time.sleep(1)
		play()
		main()

	else:
		time.sleep(1)
		main()

def check_curtime():
    fmt = "%Y-%m-%d %H:%M:%S %Z%z"
    now_time = datetime.now(timezone('US/Eastern'))
    now_est_time = now_time.strftime(fmt)
    # print(now_time.strftime("%H"))
    if now_time.strftime("%H:%M:%S") == "15:00:00":
        return True
    else:
        return False



def play():
	#set timer
	# delayTime = 3600*24
	# # delayTime = 60.0
	# threading.Timer(delayTime, play).start()
	
	curtime = strftime("%Y-%m-%d-%H-%M-%S", gmtime())
	url_to_scrape = 'http://www.cmegroup.com/tools-information/quikstrike/treasury-analytics.html'
	options = webdriver.ChromeOptions()
	options.add_argument('--start-maximized')
	browser = webdriver.Chrome(executable_path='./chromedriver/chromedriver.exe', chrome_options=options)
	browser.get(url_to_scrape)
	inmates_list = []

	iframe = browser.find_element_by_xpath("//iframe[@class='cmeIframe']")
	browser.switch_to.default_content()
	browser.switch_to.frame(iframe)
	iframe_source = browser.page_source
	
	soup = BeautifulSoup(browser.page_source, 'html.parser')
	partA = []
	partB = []
	table = soup.select("table.base-sheet tbody tr")
	for items in table:
		# data = [item.text for item in items.select("th,td")]
		# partA.append(data)
		# print(data)
		cells = items.findAll('td')
		if len(cells) > 0:
			try:
			  
			  name = cells[0].text.strip()
			  symbol = cells[1].text.strip()
			  price = cells[2].text.strip()
			  couponA = cells[3].text.strip()
			  maturityDateA = cells[4].text.strip()
			  deliveryDateA = cells[5].text.strip()
			  issueDateA = cells[6].text.strip()
			  futuresYield = cells[7].text.strip()
			  futuresDv01 = cells[8].text.strip()
			  couponB = cells[9].text.strip()
			  maturityDateB = cells[10].text.strip()
			  valueDate = cells[11].text.strip()
			  issueDateB = cells[12].text.strip()
			  otrYeild = cells[13].text.strip()
			  otrDv01 = cells[14].text.strip()
			  
			except Exception as e:
				pass
			inmateA = {'NAME':name, 'SYMBOL': symbol, 'PRICE': price, 'COUPON': couponA, 'MATURITYDATE': maturityDateA, 'DELIVERYDATE':deliveryDateA, 
			'ISSUEDATE': issueDateA, 'FUTURESYIELD': futuresYield, 'FUTURESDV01': futuresDv01 }
			partA.append(inmateA)
			inmateB = {'NAME':name, 'SYMBOL': symbol, 'PRICE': price, 'COUPON': couponB, 'MATURITYDATE': maturityDateB, 'VALUEDATE':valueDate, 
			'ISSUEDATE': issueDateB, 'OTRYIELD': otrYeild, 'OTRDV01': otrDv01 }
			partB.append(inmateB)
	with open(curtime+'_A'+'.csv', 'w', newline = '') as outfile:
		headersA = ['NAME', 'SYMBOL', 'PRICE', 'COUPON', 'MATURITYDATE', 'DELIVERYDATE', 
			'ISSUEDATE', 'FUTURESYIELD', 'FUTURESDV01'] 
		writer = csv.writer(outfile, delimiter=",", quotechar='"', quoting=csv.QUOTE_ALL)
		writer.writerow(headersA)
		for obj in partA:
			writer.writerow([obj[key] for key in headersA])
	with open(curtime+'_B'+'.csv', 'w', newline = '') as outfile:
		headersB = ['NAME', 'SYMBOL', 'PRICE', 'COUPON', 'MATURITYDATE', 'VALUEDATE', 
			'ISSUEDATE', 'OTRYIELD', 'OTRDV01'] 
		writer = csv.writer(outfile, delimiter=",", quotechar='"', quoting=csv.QUOTE_ALL)
		writer.writerow(headersB)
		for obj in partB:
			writer.writerow([obj[key] for key in headersB])
	partA = []
	partB = []
	browser.close()


main()