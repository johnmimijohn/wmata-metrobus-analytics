# Short-Term Rental Market Intelligence

A census tract level investment scoring framework for short-term rental (Airbnb) properties in Boston and San Francisco. The project blends six public data sources into a single composite score that ranks neighborhoods by risk adjusted investment attractiveness, and explains every weight behind that score.

**Stack:** Python, pandas, geopandas, OSMnx, scikit-learn, statsmodels, BERTopic, VADER, matplotlib
**Scope:** 479 census tracts across Boston and San Francisco

---

## The question

Acting as a real estate investment firm, we asked which census tracts in Boston and San Francisco offer the strongest risk adjusted Airbnb investment opportunities, and what neighborhood factors drive that performance. We worked at the census tract level because tracts capture localized differences in demand, accessibility, safety, and amenities that listing level data alone cannot reveal.

## Approach

![Project pipeline](images/pipeline.png)

The pipeline unifies six sources onto a common analytical unit, the 11 digit census tract GEOID, then models demand and rolls the drivers up into a weighted composite score.

## Data sources

Six sources were spatially joined to 479 tract polygons: Inside Airbnb listings and reviews, Census ACS demographics, crime incident data, OpenStreetMap amenities, the EPA Smart Location Database for walkability, and an NLP pass over 234,160 guest reviews. The funnel below tracks how the raw records from each source collapse onto the tract grid.

![Data funnel across all six sources](images/data_funnel.png)

## Cleaning and feature engineering

Getting trustworthy data onto one grid was the hardest part. 150K OpenStreetMap points, 11,241 listings, and about 75K crime incidents were spatially joined to the tracts. Census and EPA sentinel codes were masked to NaN and filled with city level medians so Boston and San Francisco baselines were never mixed. Eleven raw counts were converted to rates so tracts of different size became comparable, shrinking the feature space from 56 fields to 34. Five features carrying negative meaning, such as poverty and crime, were inverted before scaling so that a higher value always means more attractive for investment.

## Guest reviews: topics and sentiment

The 640K review corpus was filtered to 234,160 English, neighborhood relevant reviews before modeling. BERTopic surfaced the themes guests actually talk about, and we kept the 10 topics with clear neighborhood content such as walkability, transit, and dining.

![BERTopic topic distribution](images/bertopic_topics.png)

VADER then scored sentiment, which was aggregated to the tract level as a neighborhood sentiment ratio.

![VADER sentiment score distribution](images/sentiment_distribution.png)

## Crime labeling

Crime incidents were classified into high, medium, and low severity. Human labels based on the FBI UCR system were compared against LLM generated labels on a 100 crime sample, 50 per city, to catch classification discrepancies before the labels fed the score. Crime was then mapped per tract.

![Crime per capita, Boston](images/crime_per_capita_boston.png)

## The model

An OLS regression on the occupancy proxy identifies which features actually move demand, with a direction and a p-value for every one. These coefficients make the final weights transparent and defensible rather than arbitrary.

![OLS coefficients](images/ols_coefficients.png)

## Scoring framework

The composite score combines four categories with domain weights: Demand 35 percent, Neighborhood Quality 30 percent, Accessibility 25 percent, and Amenities 10 percent. Within each category the absolute OLS betas are renormalized so the within group weights sum to one.

![Within-group feature weights](images/scoring_weights.png)

## Results

High scoring tracts cluster in recognizable places: the downtown core and South Boston Waterfront in Boston, and two distinct hotspots in San Francisco, the Financial District corridor and a western arc through Presidio and Western Addition.

![Investment score, Boston](images/investment_score_boston.png)

![Investment score, San Francisco](images/investment_score_sf.png)

The top tracts are not interchangeable. Presidio leads on demand and quality with only 17 active listings, a high satisfaction, low competition market. Western Addition carries the highest guest sentiment in the dataset at 0.994. South Boston Waterfront tops Boston on quality, driven by a median household income near $218K and very low crime.

![Top three tracts per city](images/top_tracts.png)

## Repository structure

```
.
├── analysis.ipynb                     Full pipeline: ingest, clean, model, score
├── data/
│   └── master_db_tractlevel.csv       Tract level master table, 479 tracts
├── docs/
│   └── final_project_report.docx      Full write up with appendices
├── images/                            Figures used in this README
└── README.md
```

## How to run

Open `analysis.ipynb` and run the cells in order. The notebook pulls and cleans each source, builds the master tract table, fits the regression, and produces the scores and figures. The prepared master table is included in `data/` so the modeling and scoring sections can be run without re-fetching the raw sources.

## Team and contribution

A five person group project for BUDT 758J at the University of Maryland, Robert H. Smith School of Business. Team: Aditya Agarwal, Anaushka Taneja, Pratinav Bomireddy, Ioannis Mimigiannis, and Nikhil Nagesh.

**My role (Ioannis Mimigiannis):** I assisted with the data cleanup, labeled the crime incidents by severity, and produced the visualizations.

## Note on data

All sources are public: Inside Airbnb, OpenStreetMap, Census ACS, the EPA Smart Location Database, and city crime open data. The work is for academic and portfolio purposes.
