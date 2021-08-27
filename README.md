# necx-covid-risk
Basic calculator to detmine the odds that you'll catch COVID by racing in a cyclocross race this fall.

<b>THIS CALCULATOR IS FOR EDUCAITONAL PURPOSES ONLY - PLEASE DO NOT TAKE THESE NUMBERS AS CERTIANTY.</b>

Only you can decide what level of risk is ok for you, but we're hoping some harder numbers provide additional context and help for those trying to make decisions for themselves. The authors of this code take no responsibility for decisions made using this calculator.

Initial inputs are based on a combination of gathered data and assumptions as follows:

<b>UNDERCOUNT FACTOR</b> - The factor by which COVID cases are under-reported due to lack of testing or asymptomatic cases </br>
- White Paper (2021, US): https://www.pnas.org/content/118/31/e2103272118 [MA rate is ~1.7]  </br>
- News Article (2021, US): https://www.npr.org/sections/coronavirus-live-updates/2021/05/06/994287048/new-study-estimates-more-than-900-000-people-have-died-of-covid-19-in-u-s  </br>
- Interactive (2021, US): https://www.washington.edu/news/2021/07/26/covid-19-true-prevalence/  </br>
- <b>We set the default for this rate at 1.7 which was the predicted undercount factor for Massachusetts.</b></br>
</br>

<b>PERCENT BREAKING QUARANTINE</b> - The percentage of people who will break quarantine despite having COVID symptoms </br>
- CDC Survey (2020, USA): https://www.cdc.gov/mmwr/volumes/69/wr/mm6924e1.htm [~77.3% nationwide adhere to policies] </br>
- IPSOS-Mori (2021, UK): https://www.bbc.com/news/uk-54346001 [80% would be certain to self-isolate for travel] </br>
- <b>Taking into account these two studies we placed the default for this rate at 25%, which is probably slightly high especially in the cycling community.</b></br>
</br>

<b>OUTDOOR TRANSMISSION RATE</b> - The odds of transmitting COVID while outside in the open air </br>
- White Paper (2021, US): https://www.medrxiv.org/content/10.1101/2020.10.03.20206110v6.full [shows transmissibility in open air] </br>
- Wuhan Study (2020, China): https://onlinelibrary.wiley.com/doi/10.1111/ina.12766 [2/7324 cases outdoors, 0.027%] </br>
- Irish Study (2021, Ireland): https://www.irishtimes.com/news/ireland/irish-news/outdoor-transmission-accounts-for-0-1-of-state-s-covid-19-cases-1.4529036 [0.1% of cases] </br>
- <b>Considering the delta variant's increased transmissibility we set the default for this rate at a 1% chance, for the brief contact in staging during a cx race and the otherwise constant airflow while racing this is probably an overestimate. </b></br>
</br>
<b>Future additions</b>: </br>
- Make it not look awful </br>
- More new england states (current data pulls only from massachusetts) </br>
- Similar risk items (comparing the odds presented to common daily things) </br>
