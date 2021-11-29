BMI_fun <- function(height, weight) {
    if(is.na(height) | is.na(weight)) {
        return('NA::a')
    }

    return(weight/(height*height))
}