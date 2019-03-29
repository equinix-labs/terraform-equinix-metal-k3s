package main

import (
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"
)

type Response struct {
	IP       string `json:"ip,omitempty"`
	Hostname string `json:"hostname,omitempty"`
	City     string `json:"city,omitempty"`
	Region   string `json:"region,omitempty"`
	Country  string `json:"country,omitempty"`
	Loc      string `json:"loc,omitempty"`
	Org      string `json:"org,omitempty"`
}

func getRecord() Response {
	req, err := http.Get("http://ipinfo.io/json")
	if err != nil {
		log.Fatal(err)
	}
	body, err := ioutil.ReadAll(req.Body)
	if err != nil {
		log.Fatal(err)
	}
	var record Response
	json.Unmarshal(body, &record)
	return record
}

func response(w http.ResponseWriter, r *http.Request) {
	record := getRecord()
	host := Response{IP:record.IP,City:record.City,Region:record.Region,Country:record.Country}
	response, err := json.Marshal(host)
	if err != nil {
		log.Fatal(err)
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(response))
}

func main() {
	http.HandleFunc("/", response)
	http.ListenAndServe(":8080", nil)
}
