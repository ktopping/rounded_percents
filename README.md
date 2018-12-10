# Overview

Round percentages, ensuring that the results add up to 100%.

# Installation

``` ruby
    gem "rounded_percents", git: 'https://github.com/ktopping/rounded_percents'
```

# Usage

`RoundedPercents` extends `Array` so it responds to all the Array-like methods (e.g. `[]`, `.length`, `.sum`, etc.)
``` ruby
    require 'rounded_percents'

    values = [1, 2, 3]
    RoundedPercents.new(values)
    # => [17, 33, 50]

    RoundedPercents.new(values, precision: 1)
    # => [16.7, 33.3, 50.0]
```

## Algorithms
Specify algorithm as follows:
``` ruby
    RoundedPercents.new(values, algorithm: RoundedPercents::LAD)
```
#### LAD (Least Absolute Difference)
This is the default, described best here: https://stackoverflow.com/a/13483710
In short, round everything down, work out how far short of 100% the sum is, and assign this shortfall to prioritising those where it makes the "Least Absolute Difference". In practise, where precision=0, this means "in reverse order of decimal component".

#### LRD (Least Relative Difference)
Like the above, but tries to reassign the shortfall according to where it would make the least _relative_ difference. Discussed here: https://stackoverflow.com/a/34959983

#### LRD_AVOID_ZERO (Least Relative Difference, Avoid Zero)
More of an experiment, but - like `LRD` BUT attempts to avoid rounding down to 0.
``` ruby
  RoundedPercents.new([99.5, 0.5], algorithm: RoundedPercents::LRD)
  # => [100, 0]
  RoundedPercents.new([99.5, 0.5], algorithm: RoundedPercents::LRD_AVOID_ZERO)
  # => [99, 1]
```

#### Other Algorithms (Not Implemented)
##### "Carry the error"
https://stackoverflow.com/a/13483486

##### "Thresholds"
Proposal, `thresholds: [1, 5]` to mean that:
  * All percentages that are greater that zero, but less than 1 should be displayed as "<1".
  * All percentages that are greater than 1, but less than 5 should display as "<5".
