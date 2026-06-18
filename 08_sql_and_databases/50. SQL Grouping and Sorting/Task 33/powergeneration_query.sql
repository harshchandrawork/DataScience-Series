SELECT "Power Station",
       AVG("Monitored Cap.(MW)") AS avg_monitored_cap,
       COUNT(*) as occurence_count
FROM powergeneration
GROUP BY "Power Station"
HAVING AVG("Monitored Cap.(MW)") > 1000 AND AVG("Monitored Cap.(MW)") < 2000 AND COUNT(*) > 200
ORDER BY AVG("Monitored Cap.(MW)");
