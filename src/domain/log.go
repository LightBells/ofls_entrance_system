package domain

import (
	"time"
)

// +gen slice:"Where,Count"
type Log struct {
	ID            string
	Date          string
	Entry_time    string
	Exit_time     string
	Purpose       int
	Satisfication int
}

// 変換エラーは握りつぶしてるので注意
func (l *Log) EnterAt() time.Time {
	dateStr := l.Date + " " + l.Entry_time
	t, _ := time.Parse("2006/01/02 15:04:05", dateStr)
	return t
}

func (l1 *Log) After(l2 *Log) bool {
	return l1.EnterAt().After(l2.EnterAt())
}
