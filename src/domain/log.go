package domain

type Log struct {
	ID            string
	Date          string
	Entry_time    string
	Exit_time     string
	Purpose       int
	Satisfication int
}

type Logs []Log
