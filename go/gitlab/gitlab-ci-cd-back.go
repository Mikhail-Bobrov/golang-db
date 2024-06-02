package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"github.com/gorilla/handlers"
)

const gitlabApiToken = "key"
const gitlabApiTokenRun = "key"
const gitID = "86"

const gitlabAPIURL = "https://"

func main() {
	// gitlabApiToken := os.Getenv("GIT_API_TOKEN")
	// if gitlabApiToken == "" {
	// 	gitlabApiToken = "key"
	// }
	// gitlabApiTokenRun := os.Getenv("GIT_API_RUN")
	// if gitlabApiTokenRun == "" {
	// 	gitlabApiTokenRun = "key"
	// }
	// gitID := os.Getenv("GIT_RUNNER_ID")
	// if gitID == "" {
	// 	gitID = "86"
	// }

	corsHandler := handlers.CORS(
		handlers.AllowedOrigins([]string{"http://localhost:3000"}),
		handlers.AllowedMethods([]string{"GET", "POST", "PUT"}),
		handlers.AllowedHeaders([]string{"Content-Type", "Authorization"}),
	)
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "hi from backend")
	})
	http.Handle("/getBranches", corsHandler(http.HandlerFunc(getBranches)))
	http.Handle("/run", corsHandler(http.HandlerFunc(runPipeline)))

	port := 8080
	fmt.Printf("Server is starting on %d...\n", port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%d", port), nil))
}

func getBranches(w http.ResponseWriter, r *http.Request) {
	projectName := r.FormValue("service")
	projectID := getProjectID(projectName)
	gitlabURL := fmt.Sprintf("%s/projects/%s/repository/branches/?per_page=50", gitlabAPIURL, projectID)
	requestGitlab, err := http.NewRequest("GET", gitlabURL, nil)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	requestGitlab.Header.Set("PRIVATE-TOKEN", gitlabApiToken)

	resp, err := http.DefaultClient.Do(requestGitlab)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		http.Error(w, fmt.Sprintf("error response from GitLab API: %d", resp.StatusCode), http.StatusInternalServerError)
		return
	}

	var branches []struct {
		Name string `json:"name"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&branches); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	var branchData []map[string]string
	for _, branch := range branches {
		branchData = append(branchData, map[string]string{
			"value": branch.Name,
			"label": branch.Name,
		})
	}
	jsonData, err := json.Marshal(branchData)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.Write(jsonData)
}

func getProjectID(serviceName string) string {
	// add service here
	serviceProjectMap := map[string]string{
		"service-name1":    "11",
		"service-name2":	"12",
	}

	id, exists := serviceProjectMap[serviceName]
	if !exists {
		return ""
	}

	return id
}

type Vars struct {
	Token     string    `json:"token"`
	Ref       string    `json:"ref"`
	Variables Variables `json:"variables"`
}

type Variables struct {
	Service string `json:"SERVICE"`
	Project string `json:"PROJECT"`
	Branch  string `json:"BRANCH"`
}

func runPipeline(w http.ResponseWriter, r *http.Request) {
	var inputData struct {
		Branch  string `json:"branch"`
		Project string `json:"project"`
		Service string `json:"service"`
	}
	err := json.NewDecoder(r.Body).Decode(&inputData)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	data := Vars{
		Token: gitlabApiTokenRun,
		// Ref - it's branch where you run ci\cd
		Ref: "master",
		Variables: Variables{
			Service: inputData.Service,
			Project: inputData.Project,
			Branch:  inputData.Branch,
		},
	}

	// transfer to json
	varsToBytes, err := json.Marshal(data)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	gitlabURL := fmt.Sprintf("%s/projects/%s/trigger/pipeline", gitlabAPIURL, gitID)
	body := bytes.NewReader(varsToBytes)
	req, err := http.NewRequest("POST", gitlabURL, body)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusCreated {
		http.Error(w, fmt.Sprintf("Error to run pipeline: %d", resp.StatusCode), http.StatusInternalServerError)
		return
	}

	fmt.Fprintf(w, "https://url")
}
